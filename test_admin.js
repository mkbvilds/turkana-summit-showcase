const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  page.on('console', msg => console.log('PAGE LOG:', msg.text()));
  page.on('pageerror', err => console.error('PAGE ERROR:', err));
  
  await page.goto('http://localhost:58252/dashboard', { waitUntil: 'networkidle2' });
  
  // We can't log in easily without credentials, but we can check if syntax errors exist.
  await browser.close();
})();
