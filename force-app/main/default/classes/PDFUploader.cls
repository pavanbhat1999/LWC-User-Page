public with sharing class PDFUploader {
    
    @AuraEnabled
    public static void uploadPdfFileAndSendEmail(String base64String, String fileName, String recipientEmail) {
        try {
            // Step 1: Create a ContentVersion (Salesforce File)
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = EncodingUtil.base64Decode(base64String);
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = '/' + fileName;
            insert contentVersion;

            // Step 2: Retrieve the ContentDocumentId directly from the ContentVersion object
            ContentVersion insertedVersion = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :contentVersion.Id
                LIMIT 1
            ];

            // Step 3: Prepare the email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{recipientEmail});
            mail.setSubject('Here is your PDF');
            mail.setPlainTextBody('Please find the attached PDF file.');
            
            // Step 4: Attach the PDF to the email
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName);
            attachment.setBody(EncodingUtil.base64Decode(base64String)); // Reuse the base64 string from the input
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

            // Step 5: Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        } catch (Exception e) {
            throw new AuraHandledException('Error uploading PDF and sending email: ' + e.getMessage());
        }
    }
}
