const fs = require('fs');
const JSZip = require('jszip');

const DELIMITER = "\n\n###\n\n";

async function translateBatch(texts, retries = 3) {
  if (texts.length === 0) return [];
  
  const combinedText = texts.join(DELIMITER);
  const url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=vi&tl=en&dt=t&q=${encodeURIComponent(combinedText)}`;
  
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url);
      const data = await response.json();
      if (data && data[0]) {
        let translatedCombined = data[0].map(item => item[0]).join('');
        const translatedTexts = translatedCombined.split(/###/i).map(t => t.trim());
        
        if (translatedTexts.length === texts.length) {
            return translatedTexts;
        } else {
            console.warn(`Mismatch in chunk split: expected ${texts.length}, got ${translatedTexts.length}. Falling back to individual translation.`);
            break;
        }
      }
    } catch (e) {
      if (i === retries - 1) {
        console.error(`Batch translation failed`, e.message);
        break;
      }
      await new Promise(r => setTimeout(r, 1000 * (i + 1))); 
    }
  }
  
  // Fallback to individual
  const results = [];
  for (const text of texts) {
      results.push(await translateIndividual(text));
  }
  return results;
}

async function translateIndividual(text, retries = 3) {
  if (!text || !text.trim() || text.match(/^[0-9\W]+$/)) return text; 
  const url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=vi&tl=en&dt=t&q=${encodeURIComponent(text)}`;
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url);
      const data = await response.json();
      if (data && data[0]) {
        return data[0].map(item => item[0]).join('');
      }
    } catch (e) {}
  }
  return text;
}

async function processPresentation() {
  console.log("Loading presentation...");
  const data = fs.readFileSync('Khảo sát các phòng ban.pptx');
  const zip = await JSZip.loadAsync(data);
  
  const slideFiles = Object.keys(zip.files).filter(f => f.match(/ppt\/slides\/slide\d+\.xml$/));
  const translationMap = {};
  
  // Extract all texts first
  const allTextsToTranslate = new Set();
  
  for (const slideFile of slideFiles) {
    let content = await zip.files[slideFile].async('string');
    const regex = /<a:t>([^<]*)<\/a:t>/g;
    let match;
    while ((match = regex.exec(content)) !== null) {
      const text = match[1];
      if (text.trim() && !text.match(/^[0-9\W]+$/)) {
        allTextsToTranslate.add(text);
      }
    }
  }
  
  const uniqueTexts = Array.from(allTextsToTranslate);
  console.log(`Found ${uniqueTexts.length} unique text snippets to translate.`);
  
  // Batch processing
  const batches = [];
  let currentBatch = [];
  let currentLength = 0;
  
  for (const text of uniqueTexts) {
      const decodedText = text.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&apos;/g, "'");
      if (currentLength + decodedText.length > 2000) {
          batches.push(currentBatch);
          currentBatch = [decodedText];
          currentLength = decodedText.length;
      } else {
          currentBatch.push(decodedText);
          currentLength += decodedText.length;
      }
  }
  if (currentBatch.length > 0) batches.push(currentBatch);
  
  console.log(`Split into ${batches.length} batches.`);
  
  let translatedCount = 0;
  for (let b = 0; b < batches.length; b++) {
      const batch = batches[b];
      console.log(`Translating batch ${b+1}/${batches.length}...`);
      const translatedBatch = await translateBatch(batch);
      
      let i = 0;
      for (const text of uniqueTexts.slice(translatedCount, translatedCount + batch.length)) {
          const translated = translatedBatch[i] || text;
          const encodedTranslated = translated.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&apos;');
          translationMap[text] = encodedTranslated;
          i++;
      }
      translatedCount += batch.length;
  }
  
  console.log("Applying translations to slides...");
  for (const slideFile of slideFiles) {
    let content = await zip.files[slideFile].async('string');
    let newContent = content.replace(/<a:t>([^<]*)<\/a:t>/g, (match, p1) => {
      if (translationMap[p1]) {
        return `<a:t>${translationMap[p1]}</a:t>`;
      }
      return match;
    });
    zip.file(slideFile, newContent);
  }
  
  console.log("Saving new presentation...");
  const newContent = await zip.generateAsync({type: "nodebuffer"});
  fs.writeFileSync('Khao_sat_cac_phong_ban_EN.pptx', newContent);
  console.log("Done! Saved as Khao_sat_cac_phong_ban_EN.pptx");
}

processPresentation().catch(console.error);
