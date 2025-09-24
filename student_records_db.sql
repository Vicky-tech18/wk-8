-- student_records_db.sql
-- Create database and tables for a Student Records system
-- MySQL / InnoDB

DROP DATABASE IF EXISTS student_records_db;
CREATE DATABASE student_records_db CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_unicode_ci';
USE student_records_db;

-- Departments (One-to-Many with Courses, Professors)
CREATE TABLE departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(10) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Professors (Many Professors belong to one department)
CREATE TABLE professors (
    professor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    dept_id INT,
    CONSTRAINT fk_prof_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Students
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    dob DATE,
    matric_no VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Courses (Each course belongs to a department; a professor may teach it)
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    credits TINYINT NOT NULL DEFAULT 3,
    dept_id INT,
    professor_id INT,
    CONSTRAINT fk_course_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_course_prof FOREIGN KEY (professor_id) REFERENCES professors(professor_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Many-to-Many: enrollments (Student <-> Course)
-- Additional fields: enrolled_at, semester, grade (NULL until assigned)
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester VARCHAR(20) NOT NULL, -- e.g., '2025-01' or 'Fall 2025'
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grade VARCHAR(5),
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_course FOREIGN KEY (course_id) REFERENCES courses(course_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uc_student_course_semester UNIQUE (student_id, course_id, semester)
) ENGINE=InnoDB;

-- Example of One-to-One: a student profile could be separate; here we include a simple table
CREATE TABLE student_profiles (
    student_id INT PRIMARY KEY,
    bio TEXT,
    linkedin VARCHAR(255),
    github VARCHAR(255),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Indexes to speed common lookups
CREATE INDEX idx_students_matric ON students(matric_no);
CREATE INDEX idx_courses_code ON courses(course_code);

-- Sample data seeds
INSERT INTO departments (name, code) VALUES
('Computer Science', 'CS'),
('Mathematics', 'MTH'),
('Physics', 'PHY');

INSERT INTO professors (first_name, last_name, email, dept_id) VALUES
('Ada', 'Lovelace', 'ada.lovelace@example.edu', 1),
('Alan', 'Turing', 'alan.turing@example.edu', 1),
('Katherine', 'Johnson', 'k.johnson@example.edu', 2);

INSERT INTO students (first_name, last_name, email, dob, matric_no) VALUES
('Victoria', 'Amos', 'victoria.amos@example.com', '2005-02-18', 'CS2025001'),
('John', 'Doe', 'john.doe@example.com', '2004-09-07', 'CS2025002'),
('Emily', 'Clark', 'emily.clark@example.com', '2003-06-11', 'MTH2025001');

INSERT INTO courses (course_code, title, description, credits, dept_id, professor_id) VALUES
('COS101', 'Introduction to Computer Science', 'Basics of computing', 3, 1, 1),
('MTH101', 'Calculus I', 'Limits, derivatives, integrals', 4, 2, 3),
('PHY101', 'Physics I', 'Mechanics', 3, 3, NULL);

-- Enroll some students (many-to-many)
INSERT INTO enrollments (student_id, course_id, semester) VALUES
(1, 1, 'Fall 2025'),
(1, 2, 'Fall 2025'),
(2, 1, 'Fall 2025'),
(3, 2, 'Fall 2025');

-- Optional profile
INSERT INTO student_profiles (student_id, bio, linkedin, github) VALUES
(1, 'CS student interested in frontend development and anime', 'https://linkedin.example/victoria', 'https://github.example/victoria');

-- A view for convenience (lists student enrollments)
DROP VIEW IF EXISTS vw_student_enrollments;
CREATE VIEW vw_student_enrollments AS
SELECT s.student_id, s.first_name, s.last_name, s.matric_no, c.course_id, c.course_code, c.title, e.semester, e.grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id;
