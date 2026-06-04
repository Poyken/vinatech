const fs = require('fs');
const JSZip = require('jszip');

// Simple translation function using Google Translate API (free endpoint)
async function translateText(text, retries = 3) {
  if (!text || !text.trim()) return text;
  if (text.match(/^[0-9\W]+$/)) return text; // Skip if only numbers and symbols
  
  const url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=vi&tl=en&dt=t&q=${encodeURIComponent(text)}`;
  
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url);
      const data = await response.json();
      if (data && data[0]) {
        let translated = data[0].map(item => item[0]).join('');
        return translated;
      }
    } catch (e) {
      if (i === retries - 1) {
        console.error(`Translation failed for: "${text}"`, e.message);
        return text;
      }
      await new Promise(r => setTimeout(r, 1000 * (i + 1))); // backoff
    }
  }
  return text;
}

async function processPresentation() {
  console.log("Loading presentation...");
  const data = fs.readFileSync('Khảo sát các phòng ban.pptx');
  const zip = await JSZip.loadAsync(data);
  
  const slideFiles = Object.keys(zip.files).filter(f => f.match(/ppt\/slides\/slide\d+\.xml$/));
  
  for (const slideFile of slideFiles) {
    console.log(`Processing ${slideFile}...`);
    let content = await zip.files[slideFile].async('string');
    
    // Find all text elements
    const regex = /<a:t>([^<]*)<\/a:t>/g;
    let match;
    const textsToTranslate = [];
    
    while ((match = regex.exec(content)) !== null) {
      const text = match[1];
      if (text.trim()) {
        textsToTranslate.push(text);
      }
    }
    
    // Deduplicate to minimize API calls
    const uniqueTexts = [...new Set(textsToTranslate)];
    const translationMap = {};
    
    for (let i = 0; i < uniqueTexts.length; i++) {
      const text = uniqueTexts[i];
      // Decode XML entities for translation
      const decodedText = text.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&apos;/g, "'");
      
      const translated = await translateText(decodedText);
      
      // Encode back
      const encodedTranslated = translated.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&apos;');
      translationMap[text] = encodedTranslated;
      
      if (i % 5 === 0) {
          console.log(`  Translated ${i + 1}/${uniqueTexts.length}`);
      }
    }
    
    // Replace in content
    let newContent = content.replace(/<a:t>([^<]*)<\/a:t>/g, (match, p1) => {
      if (p1.trim() && translationMap[p1]) {
        return `<a:t>${translationMap[p1]}</a:t>`;
      }
      return match;
    });
    
    zip.file(slideFile, newContent);
  }
  
  console.log("Saving new presentation...");
  const newContent = await zip.generateAsync({type: "nodebuffer"});
  fs.writeFileSync('Department_Survey_EN.pptx', newContent);
  console.log("Done! Saved as Department_Survey_EN.pptx");
}

processPresentation().catch(console.error);
