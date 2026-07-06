package com.homestay.backend.repository;

import com.homestay.backend.entity.Article;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ArticleRepository extends JpaRepository<Article, Long> {

    List<Article> findAllByOrderByCreatedAtDesc();

    List<Article> findByAuthorIdOrderByCreatedAtDesc(String authorId);
}
