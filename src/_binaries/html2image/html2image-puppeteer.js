#!/usr/bin/env node
/**
 * HTML to Image Converter using Puppeteer
 * Converts HTML content to images (PNG, JPEG, WEBP)
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

// Parse command-line arguments
function parseArgs() {
  const args = process.argv.slice(2);
  const config = {
    inputFile: null,
    outputFile: null,
    format: 'png',
    viewport: '',
    quality: 90,
    fullPage: true,
    stdin: false,
    waitForRender: 0,
    waitForSelector: null,
    injectCss: null,
    hideSelector: null
  };

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--input':
      case '-i':
        config.inputFile = args[++i];
        break;
      case '--output':
      case '-o':
        config.outputFile = args[++i];
        break;
      case '--format':
      case '-f':
        config.format = args[++i].toLowerCase();
        break;
      case '--viewport':
      case '-v':
        config.viewport = args[++i];
        break;
      case '--quality':
      case '-q':
        config.quality = parseInt(args[++i], 10);
        break;
      case '--full-page':
        config.fullPage = true;
        break;
      case '--stdin':
        config.stdin = true;
        break;
      case '--wait-for-render':
        config.waitForRender = parseInt(args[++i], 10);
        break;
      case '--wait-for-selector':
        config.waitForSelector = args[++i];
        break;
      case '--inject-css':
        config.injectCss = args[++i];
        break;
      case '--hide-selector':
        config.hideSelector = args[++i];
        break;
      case '--help':
      case '-h':
        printHelp();
        process.exit(0);
        break;
      default:
        console.error(`Unknown option: ${args[i]}`);
        process.exit(1);
    }
  }

  return config;
}

function printHelp() {
  console.log(`
HTML to Image Converter using Puppeteer

Usage: node html2image-puppeteer.js [options]

Options:
  -i, --input <file>         Input HTML file
  -o, --output <file>        Output image file (required)
  --stdin                    Read HTML from stdin
  -f, --format <format>      Output format: png, jpg, jpeg, webp (default: png)
  -v, --viewport <size>      Viewport size in WIDTHxHEIGHT format (default: auto-fit to content)
  -q, --quality <number>     Image quality 0-100 (default: 90, for jpeg/webp)
  --full-page                Capture full scrollable page
  --wait-for-render <ms>     Extra wait (ms) after page load for JS-rendered content (default: 0)
  --wait-for-selector <sel>  CSS selector to wait for before taking screenshot
  --inject-css <file>        Inject CSS file contents into the page before screenshot
  --hide-selector <sel>      Hide the last element matching this CSS selector
  -h, --help                 Show this help

Examples:
  # Convert HTML file to PNG
  node html2image-puppeteer.js -i input.html -o output.png

  # Convert JS-rendered SPA (e.g. markwhen timeline)
  node html2image-puppeteer.js -i input.html -o output.webp -f webp --wait-for-render 2000

  # Wait for a specific element before capturing
  node html2image-puppeteer.js -i input.html -o output.png --wait-for-selector '#app'

  # Convert from stdin to WEBP
  echo "<html><body>Hello</body></html>" | node html2image-puppeteer.js --stdin -o output.webp -f webp
`);
}

async function convertHtmlToImage(config) {
  let browser;
  let tempInputFile = null;

  try {
    // Determine the file path to load in the browser
    // Using file:// URL (instead of setContent) is critical for JS-rendered SPAs:
    // setContent sets the page origin to 'null' which breaks history.pushState/replaceState
    // and other security-sensitive browser APIs that SPAs rely on.
    let inputFilePath;

    if (config.stdin) {
      // Read from stdin and write to a temp file for proper file:// URL loading
      const htmlContent = await new Promise((resolve, reject) => {
        const chunks = [];
        process.stdin.on('data', chunk => chunks.push(chunk));
        process.stdin.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
        process.stdin.on('error', reject);
      });
      const os = require('os');
      const crypto = require('crypto');
      tempInputFile = path.join(os.tmpdir(), `html2image-stdin-${crypto.randomBytes(6).toString('hex')}.html`);
      fs.writeFileSync(tempInputFile, htmlContent, 'utf8');
      inputFilePath = tempInputFile;
    } else if (config.inputFile) {
      if (!fs.existsSync(config.inputFile)) {
        throw new Error(`Input file not found: ${config.inputFile}`);
      }
      inputFilePath = config.inputFile;
    } else {
      throw new Error('Either --input or --stdin must be specified');
    }

    if (!config.outputFile) {
      throw new Error('--output is required');
    }

    // Parse viewport dimensions (if provided)
    let width = 1280;
    let height = 800;
    if (config.viewport) {
      const parts = config.viewport.split('x').map(v => parseInt(v, 10));
      if (parts.length !== 2 || !parts[0] || !parts[1] || parts[0] <= 0 || parts[1] <= 0) {
        throw new Error(`Invalid viewport format: ${config.viewport}. Use WIDTHxHEIGHT format (e.g., 2496x1664)`);
      }
      [width, height] = parts;
    }

    // Validate format
    const validFormats = ['png', 'jpg', 'jpeg', 'webp'];
    if (!validFormats.includes(config.format)) {
      throw new Error(`Invalid format: ${config.format}. Use one of: ${validFormats.join(', ')}`);
    }

    // Launch Puppeteer
    browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    });

    const page = await browser.newPage();

    // Set initial viewport
    await page.setViewport({ width, height });

    // Load via file:// URL — this gives the page a proper origin so JS SPAs
    // (Vue, React, Svelte, web components) can use history API, localStorage, etc.
    await page.goto(`file://${inputFilePath}`, {
      waitUntil: ['load', 'networkidle0']
    });

    // Wait for a specific selector if requested (useful for SPAs)
    if (config.waitForSelector) {
      try {
        await page.waitForSelector(config.waitForSelector, { timeout: 30000 });
      } catch (e) {
        console.error(`Warning: selector '${config.waitForSelector}' not found within 30s, continuing anyway`);
      }
    }

    // Flush pending rendering: two rAF cycles ensure all synchronous JS paint is done
    await page.evaluate(() => new Promise(resolve => {
      requestAnimationFrame(() => requestAnimationFrame(resolve));
    }));

    // Extra wait for JS-rendered content (SPAs, web components, animations)
    if (config.waitForRender > 0) {
      await new Promise(resolve => setTimeout(resolve, config.waitForRender));
    }

    // Inject custom CSS into the page
    if (config.injectCss) {
      if (!fs.existsSync(config.injectCss)) {
        throw new Error(`CSS file not found: ${config.injectCss}`);
      }
      const cssContent = fs.readFileSync(config.injectCss, 'utf8');
      await page.addStyleTag({ content: cssContent });
    }

    // Hide the last element matching a CSS selector (e.g. floating toolbars)
    if (config.hideSelector) {
      await page.evaluate((selector) => {
        const elements = document.querySelectorAll(selector);
        if (elements.length > 0) {
          elements[elements.length - 1].style.setProperty('display', 'none', 'important');
        }
      }, config.hideSelector);
    }

    // If no explicit viewport was given, resize the viewport to fit the page content
    if (!config.viewport) {
      const contentSize = await page.evaluate(() => ({
        width: document.documentElement.scrollWidth,
        height: document.documentElement.scrollHeight
      }));
      await page.setViewport({ width: contentSize.width, height: contentSize.height });
    }

    // Prepare screenshot options
    const screenshotOptions = {
      path: config.outputFile,
      type: config.format === 'jpg' ? 'jpeg' : config.format,
      fullPage: config.fullPage
    };

    // Add quality for jpeg and webp
    if (config.format === 'jpg' || config.format === 'jpeg' || config.format === 'webp') {
      screenshotOptions.quality = config.quality;
    }

    // Take screenshot
    await page.screenshot(screenshotOptions);

    console.log(`Successfully generated: ${config.outputFile}`);

  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  } finally {
    if (browser) {
      await browser.close();
    }
    // Clean up temp file created for stdin input
    if (tempInputFile && fs.existsSync(tempInputFile)) {
      fs.unlinkSync(tempInputFile);
    }
  }
}

// Main execution
const config = parseArgs();
convertHtmlToImage(config).catch(error => {
  console.error(`Fatal error: ${error.message}`);
  process.exit(1);
});
