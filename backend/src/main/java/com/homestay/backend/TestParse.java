package com.homestay.backend;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.Claims;

public class TestParse {
    public static void main(String[] args) {
        String token = "eyJhbGciOiJFUzI1NiIsImtpZCI6ImQ1YjQ3OTIzLWUyZGUtNDQ2MS1iMWMzLWMyZDk3MDAxZmIxNSIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3ZzbWx6bXdncXlhZHVhdnJpc21lLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI3NzA0OWJmYy1iMzExLTQ1NWMtOGY2Zi1kOWE0M2U5NGEwZTAiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzgzNjE3MDUzLCJpYXQiOjE3ODM2MTM0NTMsImVtYWlsIjoidGVzdDEyMzQ1NjdAZXhhbXBsZS5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl19LCJ1c2VyX21ldGFkYXRhIjp7ImVtYWlsIjoidGVzdDEyMzQ1NjdAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJzdWIiOiI3NzA0OWJmYy1iMzExLTQ1NWMtOGY2Zi1kOWE0M2U5NGEwZTAifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJwYXNzd29yZCIsInRpbWVzdGFtcCI6MTc4MzYxMzQ1M31dLCJzZXNzaW9uX2lkIjoiYTk0ZDJiNzctNGFiMC00NTAzLWI1MjgtNTJiMmU1MmM1NGQ1IiwiaXNfYW5vbnltb3VzIjpmYWxzZX0.ALlPaR-fyvSkRLV5wIOu1gl79uInSe0mr_1P2ajfZeUcyf3EOo8dFGUTGnr63klftDLKG-vjclTRE5g8OH7Pyw";
        try {
            String unsignedToken = token.substring(0, token.lastIndexOf('.') + 1);
            System.out.println("Unsigned token: " + unsignedToken);
            Claims claims = Jwts.parserBuilder().build().parseClaimsJwt(unsignedToken).getBody();
            System.out.println("Subject: " + claims.getSubject());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
