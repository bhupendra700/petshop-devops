import crypto from "crypto";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

import dotenv from "dotenv";
import { PutObjectCommand } from "@aws-sdk/client-s3";

import Product from "../models/productModel.js";
import s3 from "./s3.js";

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// backend/productSeedImages
const productSeedImages = path.join(
  __dirname,
  "..",
  "productSeedImages"
);

const seedProducts = async () => {
  // Check if products already exist
  const productCount = await Product.countDocuments();

  if (productCount > 0) {
    console.log(
      "Products already exist. Skipping product seeding."
    );
    return;
  }

  console.log("No products found. Seeding 10 products...");

  const products = [
    {
      name: "Premium Dog Collar",
      price: 499,
      countInStock: 25,
      category: "Toys",
      description:
        "Comfortable and adjustable premium collar for everyday use.",
      isPublished: true,
      isOnSale: false,
      salePrice: 0,
      isPopular: true,
      image: "premium-dog-collar.jpg",
    },
    {
      name: "Adjustable Dog Leash",
      price: 699,
      countInStock: 20,
      category: "Toys",
      description:
        "Strong and durable adjustable leash for daily walks and outdoor activities.",
      isPublished: true,
      isOnSale: false,
      salePrice: 0,
      isPopular: true,
      image: "adjustable-dog-leash.jpg",
    },
    {
      name: "Cute Dog Cap",
      price: 349,
      countInStock: 15,
      category: "Holidays",
      description:
        "Cute and comfortable cap designed to protect your dog from sunlight.",
      isPublished: true,
      isOnSale: true,
      salePrice: 299,
      isPopular: false,
      image: "cute-dog-cap.jpg",
    },
    {
      name: "Winter Dog Hoodie",
      price: 899,
      countInStock: 12,
      category: "Holidays",
      description:
        "Warm and comfortable hoodie for dogs during cold weather.",
      isPublished: true,
      isOnSale: false,
      salePrice: 0,
      isPopular: true,
      image: "winter-dog-hoodie.jpg",
    },
    {
      name: "Dog Raincoat",
      price: 799,
      countInStock: 10,
      category: "Holidays",
      description:
        "Water-resistant raincoat that keeps your dog comfortable during rainy walks.",
      isPublished: true,
      isOnSale: true,
      salePrice: 699,
      isPopular: false,
      image: "dog-raincoat.jpg",
    },
    {
      name: "Interactive Dog Ball",
      price: 299,
      countInStock: 30,
      category: "Toys",
      description:
        "Durable interactive ball designed to keep dogs active and entertained.",
      isPublished: true,
      isOnSale: false,
      salePrice: 0,
      isPopular: true,
      image: "interactive-dog-ball.jpg",
    },
    {
      name: "Healthy Dog Treats",
      price: 249,
      countInStock: 40,
      category: "Treats",
      description:
        "Tasty dog treats made for rewarding your pet during training.",
      isPublished: true,
      isOnSale: true,
      salePrice: 199,
      isPopular: true,
      image: "healthy-dog-treats.jpg",
    },
    {
      name: "Soft Dog Bed",
      price: 1499,
      countInStock: 8,
      category: "Holidays",
      description:
        "Soft and comfortable bed that gives your dog a cozy place to rest.",
      isPublished: true,
      isOnSale: false,
      salePrice: 0,
      isPopular: true,
      image: "soft-dog-bed.jpg",
    },
    {
      name: "Stainless Steel Dog Bowl",
      price: 599,
      countInStock: 18,
      category: "Toys",
      description:
        "Durable stainless steel bowl suitable for food and water.",
      isPublished: true,
      isOnSale: false,
      salePrice: 0,
      isPopular: false,
      image: "stainless-steel-dog-bowl.jpg",
    },
    {
      name: "Dog Birthday Party Set",
      price: 649,
      countInStock: 14,
      category: "Holidays",
      description:
        "Fun birthday accessories for celebrating your dog's special day.",
      isPublished: true,
      isOnSale: true,
      salePrice: 549,
      isPopular: false,
      image: "dog-birthday-party-set.jpg",
    },
  ];

  for (const productData of products) {
    try {
      // Local image path
      const imagePath = path.join(
        productSeedImages,
        productData.image
      );

      // Check if image exists
      if (!fs.existsSync(imagePath)) {
        throw new Error(
          `Image not found: ${imagePath}`
        );
      }

      // Read local image
      const imageBuffer = fs.readFileSync(imagePath);

      // Get extension
      const extension = path.extname(
        productData.image
      );

      // Content type
      let contentType = "image/jpeg";

      if (extension === ".png") {
        contentType = "image/png";
      } else if (extension === ".webp") {
        contentType = "image/webp";
      }

      // Generate unique S3 filename
      const fileName = `${crypto.randomUUID()}${extension}`;

      // Upload image to S3
      await s3.send(
        new PutObjectCommand({
          Bucket: process.env.AWS_S3_BUCKET_NAME,
          Key: fileName,
          Body: imageBuffer,
          ContentType: contentType,
        })
      );

      // Generate S3 URL
      const imageUrl =
        `https://${process.env.AWS_S3_BUCKET_NAME}.s3.` +
        `${process.env.AWS_REGION}.amazonaws.com/${fileName}`;

      // Create product in MongoDB
      await Product.create({
        name: productData.name,
        price: productData.price,
        countInStock: productData.countInStock,
        category: productData.category,
        description: productData.description,
        image: imageUrl,
        isPublished: productData.isPublished,
        isOnSale: productData.isOnSale,
        salePrice: productData.salePrice,
        isPopular: productData.isPopular,
      });

      console.log(
        `Product created: ${productData.name}`
      );
    } catch (error) {
      console.error(
        `Failed to seed product "${productData.name}":`,
        error.message
      );
    }
  }

  console.log("Product seeding completed.");
};

export default seedProducts;