package com.example.util;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import java.io.FileInputStream;
import java.io.IOException;

public class FirebaseInitializer {

    private static boolean initialized = false;

    public static synchronized void initialize() {
        if (initialized) {
            return;  // Already initialized, skip
        }

        try {
            // Replace with the absolute path to your Firebase Service Account JSON file
            FileInputStream serviceAccount = new FileInputStream("C:/Users/Adlina/Downloads/earlylearning-372d4-firebase-adminsdk-fbsvc-fd15d2b27a.json");

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            FirebaseApp.initializeApp(options);
            initialized = true;

            System.out.println("Firebase has been initialized successfully.");

        } catch (IOException e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to initialize Firebase", e);
        }
    }
}
