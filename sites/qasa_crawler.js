const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const BOSTAD_URL = process.env.BOSTAD_URL ||
  'https://qasa.se/en/find-home?contractTypes=firstHand&homeTypes=apartment&minRentalLength=31536000&minRoomCount=3&minSquareMeters=70&searchAreas=Stockholm~~se&sharedHome=privateHome'
const OUTPUT_FILE = path.join(__dirname, 'apartments.json');


async function fetchApartments(page) {

const listings =  await page.evaluate(() => {
  // Function to extract the price as an integer
  function extractPrice(price) {
    if (price.includes('–')) {
      price = price.split('–')[0].trim();
    }
    return parseInt(price.replace(/[^0-9]/g, ''), 10);
  }

  const items = document.querySelectorAll('div.qds-r04387 a[target="_self"]');
  return Array.from(items).map(item => {
    const linkElement = item;
    const link = linkElement ? 'https://qasa.se' + linkElement.getAttribute('href') : '';
    const area = item.querySelector('div.qds-2opy0w h2.qds-kygmpv')?.innerText || '';
    const address = item.querySelector('div.qds-2opy0w h2.qds-kygmpv')?.innerText || '';
    const priceText = item.querySelector('div.qds-2opy0w p.qds-h84sg7')?.innerText || '';
    const priceInt = extractPrice(priceText);

    return { link, area, address, priceText, priceInt };
  });
});

  return listings;
}


async function saveApartments(apartments) {
  try {
    console.log(apartments);
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