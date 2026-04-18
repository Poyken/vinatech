import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI('AIzaSyAe-OIiYbd4BLnfyNXK4PPjZaaQ9XXChMw');

async function testModel(modelName) {
  try {
    const model = genAI.getGenerativeModel({ model: modelName });
    const result = await model.generateContent('Hi');
    console.log(`[SUCCESS] ${modelName}:`, result.response.text().slice(0, 50));
  } catch (err) {
    if (err.message.includes('429')) {
      console.log(`[QUOTA 0] ${modelName}`);
    } else {
      console.log(`[FAILED] ${modelName}:`, err.message);
    }
  }
}

async function run() {
  await testModel('gemini-2.5-flash');
  await testModel('gemini-flash-latest');
  await testModel('gemini-3.1-pro-preview');
}

run();
