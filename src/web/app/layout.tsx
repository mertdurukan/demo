import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Kullanıcı Giriş Sistemi",
  description: "Basit kullanıcı giriş uygulaması",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="tr">
      <body>
        {children}
      </body>
    </html>
  );
}
