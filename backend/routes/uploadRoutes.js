import path from "path";
import express from "express";
import multer from "multer";
import crypto from "crypto";
import { DeleteObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import s3 from "../config/s3.js";
import dotenv from "dotenv";
dotenv.config();
const router = express.Router();

const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new Error("Only image files are allowed"));
    }
  },
});

router.post("/", upload.single("image"), async (req, res) => {
  if (req.body.product) {
    const productData = JSON.parse(req.body.product);

    if (productData.image) {
      const imageUrl = new URL(productData.image);
      const key = decodeURIComponent(
        imageUrl.pathname.substring(1)
      );

      await s3.send(
        new DeleteObjectCommand({
          Bucket: process.env.AWS_S3_BUCKET_NAME,
          Key: key,
        })
      );
    }
  }

  if (!req.file) {
    res.status(400);
    throw new Error("Please select an image");
  }

  const extension = path.extname(req.file.originalname);
  const fileName = `${crypto.randomUUID()}${extension}`;

  const command = new PutObjectCommand({
    Bucket: process.env.AWS_S3_BUCKET_NAME,
    Key: fileName,
    Body: req.file.buffer,
    ContentType: req.file.mimetype,
  });

  await s3.send(command);

  const imageUrl = `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/${fileName}`;

  res.send({
    message: "Image uploaded",
    image: imageUrl,
  });
});

export default router;
