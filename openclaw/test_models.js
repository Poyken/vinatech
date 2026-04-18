import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI('AIzaSyAe-OIiYbd4BLnfyNXK4PPjZaaQ9XXChMw');

async function run() {
  try {
    // There is no direct listModels in the JS SDK standard exports sometimes, let's fetch REST directly
    const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=AIzaSyAe-OIiYbd4BLnfyNXK4PPjZaaQ9XXChMw`);
    const data = await res.json();
    console.log(data.models.filter(m => m.supportedGenerationMethods.includes('generateContent')).map(m => m.name));
  } catch (err) {
    console.error(err);
  }
}

run();
