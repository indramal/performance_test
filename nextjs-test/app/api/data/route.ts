import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({
    subtitle: "The react / rust fullstack framework",
  });
}
