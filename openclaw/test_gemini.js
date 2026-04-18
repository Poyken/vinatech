import { chromium } from 'playwright';

(async () => {
  console.log('Connecting to Chrome...');
  const browser = await chromium.connectOverCDP('http://localhost:9222');
  const context = browser.contexts()[0];
  
  console.log('Opening Gemini...');
  const page = await context.newPage();
  await page.goto('https://gemini.google.com/app', { waitUntil: 'networkidle' });
  
  // Wait a few seconds to let it load
  await page.waitForTimeout(3000);
  
  console.log('Typing prompt...');
  // Find the chat input
  const inputSelector = 'div[contenteditable="true"], textarea';
  await page.waitForSelector(inputSelector);
  
  // Fill the prompt
  await page.fill(inputSelector, 'Hi, this is a test from Playwright. Please reply with "TEST OK"');
  await page.keyboard.press('Enter');
  
  console.log('Waiting for response...');
  // Provide enough time for animation and generation
  await page.waitForTimeout(10000);
  
  // Extract response
  console.log('Extracting response...');
  // Usually the last assistant message
  const messages = await page.evaluate(() => {
    // Selectors from openclaw-zero-token or typical Gemini markup
    const responseEls = document.querySelectorAll('message-content, .message-content, [data-test-id="response-text"]');
    return Array.from(responseEls).map(el => el.textContent);
  });
  
  console.log('Latest response:');
  console.log(messages[messages.length - 1]);
  
  await page.close();
  await browser.close();
  console.log('Done');
})();
