const sharp = require("sharp");
const path = require("path");
const fs = require("fs");

// Get arguments
const [, , inputPath, outputPath, options] = process.argv;

// Verify input file exists
if (!fs.existsSync(inputPath)) {
  console.error(
    JSON.stringify({
      success: false,
      error: `Input file not found: ${inputPath}`,
    })
  );
  process.exit(1);
}

// Verify output directory exists
const outputDir = path.dirname(outputPath);
if (!fs.existsSync(outputDir)) {
  console.error(
    JSON.stringify({
      success: false,
      error: `Output directory not found: ${outputDir}`,
    })
  );
  process.exit(1);
}

const parsedOptions = JSON.parse(options);

// Process the image
sharp(inputPath)
  .resize({
    width: parsedOptions.maxWidth,
    height: parsedOptions.maxHeight,
    fit: "inside",
    withoutEnlargement: true,
  })
  .toFormat(parsedOptions.format, {
    quality: parsedOptions.quality,
    ...(parsedOptions.format === "webp" && {
      effort: 6,
      lossless: false,
    }),
    ...(parsedOptions.format === "avif" && {
      effort: 6,
      chromaSubsampling: "4:4:4",
    }),
  })
  .toFile(outputPath)
  .then(() => {
    console.log(
      JSON.stringify({
        success: true,
        inputPath,
        outputPath,
      })
    );
    process.exit(0);
  })
  .catch((error) => {
    console.error(
      JSON.stringify({
        success: false,
        error: error.message,
        inputPath,
        outputPath,
      })
    );
    process.exit(1);
  });
