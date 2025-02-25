import { Geist, Geist_Mono, Quicksand } from "next/font/google";

import "@workspace/ui/globals.css";
// import "@/app/globals.css"
import Header from "@/components/header";
import Footer from "@/components/layout/footer";
import { Providers } from "@/components/providers";
import { Metadata } from "next";

const fontSans = Geist({
  subsets: ["latin"],
  variable: "--font-sans",
});

const fontMono = Geist_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
});

const fontQuicksand = Quicksand({
  subsets: ["latin"],
  variable: "--font-quicksand",
  weight: ["300", "400", "500", "600", "700"],
});

export const metadata: Metadata = {
  title: "Drag-N-Convert",
  description: "Drag and drop images to convert, resize and compress",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang='en' suppressHydrationWarning>
      <body
        className={`${fontSans.variable} ${fontMono.variable} ${fontQuicksand.variable} font-[Quicksand] antialiased `}
      >
        <Providers>
          <Header />
          {children}
          <Footer />
        </Providers>
      </body>
    </html>
  );
}
