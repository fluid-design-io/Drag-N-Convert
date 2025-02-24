const sharp = require("sharp");
const path = require("path");
const fs = require("fs");

// Configure Sharp concurrency based on system cores
const concurrency = process.env.SHARP_CONCURRENCY;
if (concurrency) {
  sharp.concurrency(parseInt(concurrency, 10));
  console.error(`Sharp concurrency set to ${concurrency}`);
}

// Get command line arguments
const [, , batchDir] = process.argv;

if (!batchDir) {
  console.error("No batch directory provided");
  process.exit(1);
}

// Read batch configuration
const batchConfigPath = path.join(batchDir, "batch-config.json");
if (!fs.existsSync(batchConfigPath)) {
  console.error("Batch configuration not found");
  process.exit(1);
}

const batchConfig = JSON.parse(fs.readFileSync(batchConfigPath, "utf8"));
const { tasks } = batchConfig;

// Process all images concurrently
Promise.all(
  tasks.map(async (task) => {
    const { inputPath, outputPath, options } = task;

    try {
      await sharp(inputPath)
        .resize({
          width: options.maxWidth,
          height: options.maxHeight,
          fit: "inside",
          withoutEnlargement: true,
        })
        .toFormat(options.format, {
          quality: options.quality,
          ...(options.format === "webp" && {
            effort: 6,
            lossless: false,
          }),
          ...(options.format === "avif" && {
            effort: 6,
            chromaSubsampling: "4:4:4",
          }),
        })
        .toFile(outputPath);

      return {
        success: true,
        inputPath,
        outputPath,
      };
    } catch (error) {
      console.error(`Error processing ${inputPath}: ${error.message}`);
      return {
        success: false,
        error: error.message,
        inputPath,
        outputPath,
      };
    }
  })
)
  .then((results) => {
    // Write results to output file
    fs.writeFileSync(
      path.join(batchDir, "batch-results.json"),
      JSON.stringify(results, null, 2)
    );
    process.exit(0);
  })
  .catch((error) => {
    console.error("Batch processing failed:", error);
    process.exit(1);
  });
