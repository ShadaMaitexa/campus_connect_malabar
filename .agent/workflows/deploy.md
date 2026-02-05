---
description: How to deploy the web part to Netlify and build the APK
---

### Web Deployment (Netlify)

1.  **Build the Web App**:
    ```bash
    flutter build web --release
    ```
2.  **Deploy to Netlify**:
    -   Log in to [Netlify](https://www.netlify.com/).
    -   Select **"Add new site"** -> **"Deploy manually"**.
    -   Drag and drop the `build/web` folder from your project directory.
    -   Wait for the deployment to finish.

### Mobile App Build (APK)

1.  **Build the Release APK**:
    ```bash
    flutter build apk --release
    ```
2.  **Locate the APK**:
    -   The built APK will be located at:
        `build/app/outputs/flutter-apk/app-release.apk`
3.  **Distribute**:
    -   Upload this file to your hosting or send it directly to users.

### Project Roles Overview

-   **Web Interface**:
    -   **Landing Page**: For all guest visitors.
    -   **Admin Dashboard**: Manage users, jobs, events, and library.
    -   **Library Dashboard**: Manage books, issues, and fines.
-   **Mobile App**:
    -   **All Roles**: Student, Mentor, Alumni, Admin, and Library are all accessible via the app.
    -   **Mobile Exclusive**: Student and Mentor features are prioritized for the mobile experience.
