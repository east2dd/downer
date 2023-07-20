console.log("PDF downloader");

// script.js
document.addEventListener("DOMContentLoaded", () => {
  setTimeout(() => {
    // const pdfObject = document.querySelector(".embedded-pdf-styles");
    // const link = document.querySelector(".PdfEmbed a");
    // link.setAttribute("target", "");
    // link.click();

    const link = document.querySelector(".ViewPDF a");
    console.log(link.getAttribute("href"));
    window.location.href = link.getAttribute("href");
  }, 2000);
});
