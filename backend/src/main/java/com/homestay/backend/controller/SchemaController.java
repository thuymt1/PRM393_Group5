package com.homestay.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import java.util.Map;

@RestController
public class SchemaController {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/api/dev/schema")
    public List<Map<String, Object>> getSchema() {
        return jdbcTemplate.queryForList(
            "SELECT table_name, column_name, data_type, is_nullable " +
            "FROM information_schema.columns " +
            "WHERE table_schema = 'public' " +
            "ORDER BY table_name, ordinal_position;"
        );
    }
}
