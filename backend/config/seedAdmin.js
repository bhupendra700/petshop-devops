import User from "../models/userModel.js";

const seedAdmin = async () => {
  const { ADMIN_NAME, ADMIN_EMAIL, ADMIN_PASSWORD } = process.env;

  // If any admin credentials are missing, don't create admin
  if (!ADMIN_NAME || !ADMIN_EMAIL || !ADMIN_PASSWORD) {
    console.log("Admin credentials not found. Skipping admin creation.");
    return;
  }

  // Check if admin/user already exists with this email
  const existingUser = await User.findOne({ email: ADMIN_EMAIL });

  if (existingUser) {
    console.log("Admin already exists. Skipping admin creation.");
    return;
  }

  // Create admin
  const admin = await User.create({
    name: ADMIN_NAME,
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD,
    isAdmin: true,
  });

  console.log(`Admin user created: ${admin.email}`);
};

export default seedAdmin;