import request from "supertest";
import app from "./server.js";

test("GET / returns API is running", async () => {
  const response = await request(app).get("/");

  expect(response.statusCode).toBe(200);
  expect(response.text).toBe("Api is running...");
});