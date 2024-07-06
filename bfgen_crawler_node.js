const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const BOSTAD_URL = process.env.BOSTAD_URL ||
  'https://bostad.stockholm.se/bostad?minAntalRum=3&kanAnmalaIntresse=1&vanlig=1&omrade=%5B%7B%22value%22%3A%22Kommun-206%22%2C%22name%22%3A%22Stockholm%22%7D%5D&sort=annonserad-fran-desc';
const OUTPUT_FILE = path.join(__dirname, 'apartments.json');

function extractPrice(price) {
  if (price.includes('–')) {
    price = price.split('–')[0].trim();
  }
  return parseInt(price.replace(/[^0-9]/g, ''), 10);
}

async function fetchApartments(page) {
  return await page.evaluate(extractPriceString => {
    const extractPrice = eval(extractPriceString);

    const listings = [];
    document.querySelectorAll('.ad-list__item').forEach(item => {
      const area = item.querySelector('.apartment-listing__item__area')?.innerText || '';
      const address = item.querySelector('.ad-list__title strong')?.innerText || '';
      let link = item.querySelector('.ad-list__link')?.getAttribute('href') || '';
      if (link) {
        link = 'https://bostad.stockholm.se' + link;
      }
      const price = item.querySelector('.ad-list__data span')?.innerText || '';
      const priceInt = extractPrice(price);

      listings.push({ area, address, link, price, priceInt });
    });
    return listings;
  }, `(${extractPrice.toString()})`);
}

async function saveApartments(apartments) {
  try {
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(apartments, null, 2));
    console.log(`Saved ${apartments.length} apartments to ${OUTPUT_FILE}`);
  } catch (error) {
    console.error('Failed to save apartments:', error);
  }
}

async function main() {
  let browser;
  try {
    browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    await page.goto(BOSTAD_URL, { waitUntil: 'networkidle2' });

    const apartments = await fetchApartments(page);
    await saveApartments(apartments);
  } catch (error) {
    console.error('Error in main function:', error);
  } finally {
    if (browser) {
      await browser.close();
    }
  }
}

main();