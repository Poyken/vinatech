const fs = require('fs');
const JSZip = require('jszip');

async function extractText() {
  const data = fs.readFileSync('Khảo sát các phòng ban.pptx');
  const zip = await JSZip.loadAsync(data);
  
  // List all files in the zip
  const slideFiles = Object.keys(zip.files).filter(f => f.match(/ppt\/slides\/slide\d+\.xml$/)).sort();
  
  console.log('=== SLIDE FILES ===');
  console.log(slideFiles.join('\n'));
  
  for (const slideFile of slideFiles) {
    const content = await zip.files[slideFile].async('string');
    // Extract all text between <a:t> tags
    const textMatches = content.match(/<a:t>([^<]*)<\/a:t>/g);
    if (textMatches) {
      console.log(`\n=== ${slideFile} ===`);
      textMatches.forEach(m => {
        const text = m.replace(/<a:t>/, '').replace(/<\/a:t>/, '');
        if (text.trim()) console.log(`  "${text}"`);
      });
    }
  }
}

extractText().catch(console.error);
