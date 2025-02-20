import { connection } from "next/server";

export async function CopyrightText() {
  await connection();
  const currentTime = Date.now();
  const year = new Date(currentTime).getFullYear();
  const copyright = `© ${year} Oliver Pan`;

  return <span>{copyright}</span>;
}
