console.log("PDF downloader");

// script.js
document.addEventListener("DOMContentLoaded", () => {
  setTimeout(() => {
    // const pdfObject = document.querySelector(".embedded-pdf-styles");
    // const link = document.querySelector(".PdfEmbed a");
    // link.setAttribute("target", "");
    // link.click();

    const link = document.querySelector(".ViewPDF a");
    if (link) {
      console.log(link.getAttribute("href"));
      window.location.href = link.getAttribute("href");
    } else {
      console.log("Missing PDF Link!!!");
      window.location.href = "https://google.com";
    }
  }, 1000);
});
