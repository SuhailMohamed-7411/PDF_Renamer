# Google Drive POM PDF Renamer

This repository contains a Google Apps Script designed to automate the standardization of PDF document names within a specific Google ShareDrive folder. 

Specifically, this script targets Proactive Outreach Manager (POM) documents and enforces a strict, unified naming convention.

## Naming Convention
**Target Format:** `Product Name_Version_Document Name.pdf`
**Example:** `POM_3.1.2_Developer Guide.pdf`

### Features
When the script analyzes a file (e.g., `AvayaProactiveOutreachManager3.1.2DatabaseDictionaryforOracle.pdf`), it performs the following intelligent cleanups:
1. **Product Standardization:** Removes long product names like `AvayaProactiveOutreachManager` and enforces the standard `POM` prefix.
2. **Version Extraction:** Automatically locates and extracts version numbers, converting formats like `R312` or `312` into the standard `X.X.X` format (e.g., `3.1.2`).
3. **Readability Formatting:** Automatically splits squished CamelCase words (e.g., `DeveloperGuide` to `Developer Guide`) and removes leftover underscores or dashes to ensure a clean document name.

## Installation & Usage

1. Open [Google Apps Script](https://script.google.com/) and create a **New Project**.
2. Copy the contents of `renamePOMFiles.js` into the code editor, replacing any existing code.
3. Locate your target Google Drive **Folder ID** (the string of characters at the end of your Google Drive folder URL).
4. Replace `'YOUR_FOLDER_ID_HERE'` on line 3 of the script with your actual Folder ID.
5. Click the **Save** icon.
6. Click **Run** to execute the script manually, or click the **Triggers** icon (the clock) to set it to run automatically on a recurring schedule (e.g., every hour).

## Source Code (`renamePOMFiles.js`)

```javascript
function renamePOMFiles() {
  // 1. Replace with your specific ShareDrive Folder ID
  var folderId = 'YOUR_FOLDER_ID_HERE'; 
  
  try {
    var folder = DriveApp.getFolderById(folderId);
    var files = folder.getFilesByType(MimeType.PDF);
    
    while (files.hasNext()) {
      var file = files.next();
      var originalName = file.getName();
      var nameWithoutExt = originalName.replace(/\.pdf$/i, '');
      
      // Skip files that already match the convention (POM_X.X.X_)
      if (/^POM_\d\.\d\.\d_/.test(originalName)) {
        Logger.log('Skipped (already formatted): ' + originalName);
        continue;
      }

      // --- PARSING LOGIC ---
      // 1. Standardize Product Name
      var productName = "POM";
      var workingName = nameWithoutExt.replace(/AvayaProactiveOutreachManager|POM/i, '');
      
      // 2. Extract and Standardize Version
      var version = "UnknownVersion";
      // Looks for R312, 3.1.2, 312, etc.
      var versionMatch = workingName.match(/R?(\d)[\._]?(\d)[\._]?(\d)/i);
      
      if (versionMatch) {
        // Construct the X.X.X format
        version = versionMatch[1] + "." + versionMatch[2] + "." + versionMatch[3];
        // Remove the version from our working string
        workingName = workingName.replace(versionMatch[0], '');
      }

      // 3. Clean up the Document Name
      // Remove leftover underscores or dashes
      workingName = workingName.replace(/^_+|_+$|^-+|-+$/g, '');
      
      // Attempt to add spaces before Capital letters to fix squished words 
      // (e.g., DeveloperGuide -> Developer Guide)
      workingName = workingName.replace(/([a-z])([A-Z])/g, '$1 $2');
      workingName = workingName.replace(/([A-Z])([A-Z][a-z])/g, '$1 $2');
      
      var documentName = workingName.trim();
      
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
