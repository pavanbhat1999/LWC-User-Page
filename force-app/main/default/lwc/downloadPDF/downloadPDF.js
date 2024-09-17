import { LightningElement } from 'lwc';
import jsPDFLibrary from '@salesforce/resourceUrl/jsPDFLibrary';
import { loadScript } from 'lightning/platformResourceLoader';
import uploadPdfFileAndSendEmail from '@salesforce/apex/PDFUploader.uploadPdfFileAndSendEmail';
import storage from '@salesforce/apex/OrgLimitMonitor.fetchGovernorLimits';

export default class DownloadPDF extends LightningElement {
    jsPDFInitialized = false;
    recipientEmail = 'prbhat07@gmail.com'; // Store recipient email

    // Rendered Callback to Load jsPDF
    renderedCallback() {
        if (!this.jsPDFInitialized) {
            this.jsPDFInitialized = true;
            loadScript(this, jsPDFLibrary)
                .then(() => {
                    console.log('jsPDF library loaded successfully');
                })
                .catch((error) => {
                    console.log('Error loading jsPDF library', error);
                });
        }
    }

    // Capture the recipient's email input
    handleEmailChange(event) {
        this.recipientEmail = event.target.value;
    }

    // Generate PDF and send it via email
    async generatePDF() {
        if (this.jsPDFInitialized) {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();
            let value = await storage();
          // Set font styles
          doc.setFont('helvetica', 'bold');  // Set font to Helvetica bold
          doc.setFontSize(16);               // Set font size to 16
          doc.setTextColor(0, 0, 255);       // Set text color to blue

          // Add text to PDF
          doc.text('Salesforce Governor Limits:', 10, 20);
          
          // Set different text color for the fetched value
          doc.setTextColor(0, 128, 0);       // Set text color to green
          doc.setFont('times', 'normal');    // Change font to Times, normal
          doc.setFontSize(12);               // Set font size to 12
          doc.text(value, 10, 30);           // Print the fetched governor limits

          // Add a red filled rectangle for styling
          doc.setFillColor(255, 0, 0);       // Set fill color to red
          doc.rect(10, 40, 190, 10, 'F');    // Draw a filled rectangle

          // Add a styled section in the rectangle
          doc.setTextColor(255, 255, 255);   // Set text color to white
          doc.text('Styled Section', 15, 47);
            const pdfOutput = doc.output('blob'); // Get the PDF blob object

            const reader = new FileReader();
            reader.onloadend = () => {
                const base64PDF = reader.result.split(',')[1]; // Get base64 encoded PDF
                // Call Apex to upload the base64 PDF and send an email
                uploadPdfFileAndSendEmail({ 
                    base64String: base64PDF, 
                    fileName: 'sample.pdf', 
                    recipientEmail: this.recipientEmail // Send recipient's email to Apex
                })
                .then(() => {
                    console.log('PDF uploaded and email sent successfully');
                })
                .catch((error) => {
                    console.log('Error uploading PDF and sending email', error);
                });
            };
            reader.readAsDataURL(pdfOutput); // Read the blob as Data URL
        }
    }
}
