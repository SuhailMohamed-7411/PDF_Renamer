# Google Drive AEP PDF Renamer

This repository contains a Google Apps Script designed to automate the standardization of PDF document names within a specific Google ShareDrive folder. 

Specifically, this script targets Avaya Experience Portal (AEP) documents and enforces a strict, unified naming convention.

## Naming Convention
**Target Format:** `Product Name_Version_Document Name.pdf`
**Example:** `AEP_8.1.1_Release Notes.pdf`

### Features
When the script analyzes a file (e.g., `AdministeringAvayaExperiencePortal_R8.1.1_Feb_2022_Issue2.0.pdf`), it performs the following intelligent cleanups:
1. **Product Standardization:** Converts variations like `AvayaExperiencePortal` or `Avaya_Experience_Portal` to the standard `AEP` prefix.
2. **Version Extraction:** Automatically locates and extracts version numbers (like `R8.1.1` to `8.1.1`).
3. **Noise Removal:** Strips out unnecessary metadata such as publication dates (e.g., `Feb_2022`), issue numbers (`Issue2.0`), and file iterations (`v1.3`).
4. **Readability Formatting:** Automatically splits squished CamelCase words (e.g., `DialogflowIntegration` to `Dialogflow Integration`) and replaces underscores with spaces.

## Installation & Usage

1. Open [Google Apps Script](https://script.google.com/) and create a **New Project**.
2. Copy the contents of `renameAEPFiles.js` into the code editor, replacing any existing code.
3. Locate your target Google Drive **Folder ID** (the string of characters at the end of your Google Drive folder URL).
4. Replace `'YOUR_FOLDER_ID_HERE'` on line 3 of the script with your actual Folder ID.
5. Click the **Save** icon.
6. Click **Run** to execute the script manually, or click the **Triggers** icon (the clock) to set it to run automatically on a recurring schedule (e.g., every hour).

## Source Code (`renameAEPFiles.js`)

```javascript
function renameAEPFiles() {
  // 1. Replace with your specific ShareDrive Folder ID
  var folderId = 'YOUR_FOLDER_ID_HERE'; 
  
  try {
    var folder = DriveApp.getFolderById(folderId);
    var files = folder.getFilesByType(MimeType.PDF);
    
    while (files.hasNext()) {
      var file = files.next();
      var originalName = file.getName();
      var nameWithoutExt = originalName.replace(/\.pdf$/i, '');
      
      // Skip files that already match the convention (AEP_X.X.X_)
      if (/^AEP_\d\.\d\.\d_/.test(originalName)) {
        Logger.log('Skipped (already formatted): ' + originalName);
        continue;
      }

      // --- PARSING LOGIC ---
      // 1. Standardize Product Name to "AEP"
      var productName = "AEP";
      
      // Clean up product variations and replace underscores with spaces to normalize
      var workingName = nameWithoutExt
        .replace(/Avaya[_\s]?Experience[_\s]?Portal|AvayaExperiencePortal/ig, '')
        .replace(/_/g, ' '); // Replace underscores with spaces

      // 2. Extract and Standardize Version (e.g., 8.1.1)
      var version = "UnknownVersion";
      var versionMatch = workingName.match(/R?(\d)[\._]?(\d)[\._]?(\d)/i);
      
      if (versionMatch) {
        version = versionMatch[1] + "." + versionMatch[2] + "." + versionMatch[3];
        // Remove the matched version number from the name
        workingName = workingName.replace(versionMatch[0], '');
      }

      // 3. Clean up noise (dates, issue numbers, version iterations like v1.3)
      workingName = workingName
        // Remove dates (e.g., Feb 2022)
        .replace(/\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*[\s_]?\d{4}\b/i, '')
        // Remove document issue versions (e.g., Issue2.0, Issue 2.0)
        .replace(/Issue[\s_]?\d+\.\d+/i, '')
        // Remove file version tags (e.g., v1.3, v2)
        .replace(/\bv\d+(\.\d+)?\b/i, '');

      // 4. Add spaces to squished words (e.g., DialogflowIntegration -> Dialogflow Integration)
      workingName = workingName.replace(/([a-z])([A-Z])/g, '$1 $2');
      workingName = workingName.replace(/([A-Z])([A-Z][a-z])/g, '$1 $2');

      // 5. Final Trim
      // Clean up multiple spaces, leading/trailing spaces, hyphens, and underscores
      var documentName = workingName
        .replace(/[\s\-_]+/g, ' ') 
        .trim();

      // --- CONSTRUCT AND RENAME ---
      var newName = productName + '_' + version + '_' + documentName + '.pdf';
      
      // Execute the rename
      file.setName(newName);
      Logger.log('Renamed: ' + originalName + ' -> ' + newName);
    }
  } catch (e) {
    Logger.log('Error: ' + e.toString());
  }
}
