-- 10 records into the student table
INSERT INTO student (studentId, studentName, gender, address, email)
VALUES
    (1, 'John Doe', 'M', '123 Main St City A', 'john.doe@example.com'),
    (2, 'Alice Smith', 'F', '456 Elm St City B', 'alice.smith@example.com'),
    (3, 'Bob Johnson', 'M', '789 Oak St City C', 'bob.johnson@example.com'),
    (4, 'Emma Brown', 'F', '321 Pine St City D', 'emma.brown@example.com'),
    (5, 'Michael Davis', 'M', '654 Maple St City E', 'michael.davis@example.com'),
    (6, 'Sarah Wilson', 'F', '987 Cedar St City F', 'sarah.wilson@example.com'),
    (7, 'Ryan Martinez', 'M', '135 Birch St City G', 'ryan.martinez@example.com'),
    (8, 'Olivia Taylor', 'F', '246 Walnut St City H', 'olivia.taylor@example.com'),
    (9, 'David White', 'M', '579 Pineapple St City I', 'david.white@example.com'),
    (10, 'Sophia Rodriguez', 'F', '864 Orange St City J', 'sophia.rodriguez@example.com'),
    (11, 'Phurpa Wangchuk', 'M', '102 Orange St City J', 'phurpa.rodriguez@example.com'),
    (12, 'Dann Astony', 'M', 'H3 MIU St City J', 'dann.rodriguez@example.com'),
    (13, 'Marc Kuty', 'M', 'H5 MIU St City K', 'marck.rodriguez@example.com');

-- 10 records into the assignment table
INSERT INTO assignment (assignmentId, assign_due_date, assign_description, assign_created_date)
VALUES
    (1, '2024-05-10', 'Essay on Literature', '2024-05-01'),
    (2, '2024-05-15', 'Math Quiz', '2024-05-03'),
    (3, '2024-05-20', 'Science Project', '2024-05-05'),
    (4, '2024-05-12', 'History Paper', '2024-05-02'),
    (5, '2024-05-18', 'Computer Science Assignment', '2024-05-04'),
    (6, '2024-05-22', 'Art Project', '2024-05-06'),
    (7, '2024-05-14', 'Music Composition', '2024-05-07'),
    (8, '2024-05-25', 'Physics Experiment', '2024-05-08'),
    (9, '2024-05-28', 'Geography Presentation', '2024-05-09'),
    (10, '2024-05-30', 'Language Exercise', '2024-05-10'),
   (11, '2024-05-05', 'DB ERD', '2024-05-04'),
   (12, '2024-05-06', 'DDL Query', '2024-05-05'),
   (13, '2024-05-07', 'DML Query', '2024-05-06'),
   (14, '2024-05-07', 'ER Diagram', '2024-05-06'),
   (15, '2024-05-07', 'ER Diagram', '2024-05-06'),
   (16, '2024-05-07', 'ER Diagram', '2024-05-06'),
   (17, '2024-05-07', 'Basic SQL', '2024-05-06'),
   (18, '2024-05-07', 'Basic SQL', '2024-05-06'),
   (19, '2024-05-07', 'Advance SQL', '2024-05-06'),
   (20, '2024-05-07', 'Advance SQL', '2024-05-06');


--  10 records into the student_assignment table
INSERT INTO student_assignment (assignmentId, assignment_numeric_grade, assignment_letter_grade,
                                assignment_submission_date, assignment_graded_date,
                                assignment_returned_date, studentId)
VALUES
    (1, 85, 'B+', '2024-05-03', '2024-05-10', '2024-05-12', 1),
    (2, 92, 'A', '2024-05-05', '2024-05-12', '2024-05-14', 2),
    (3, 78, 'C+', '2024-05-07', '2024-05-14', '2024-05-16', 3),
    (4, 95, 'A', '2024-05-10', '2024-05-18', '2024-05-20', 4),
    (5, 80, 'B', '2024-05-12', '2024-05-20', '2024-05-22', 5),
    (6, 88, 'B+', '2024-05-14', '2024-05-22', '2024-05-24', 6),
    (7, 92, 'A', '2024-05-16', '2024-05-25', '2024-05-27', 7),
    (8, 85, 'B+', '2024-05-18', '2024-05-27', '2024-05-29', 8),
    (9, 90, 'A-', '2024-05-20', '2024-06-01', '2024-06-03', 9),
    (10, 94, 'A', '2024-05-22', '2024-06-03', '2024-06-05', 10),
    (11, 0, null, null, null, null, 1),
    (12, 0, null, null, null, null, 2),
    (13, 0, null, null, null, null, 3),
    (14, 85, 'B+', '2024-05-04', '2024-05-10', '2024-05-12', 1),
    (15, 92, 'A', '2024-05-05', '2024-05-12', '2024-05-14', 1),
    (16, 78, 'C+', '2024-05-07', '2024-05-14', '2024-05-16', 3),
    (17, 95, 'A', '2024-05-10', '2024-05-18', '2024-05-20', 2),
    (18, 78, 'C+', '2024-05-07', '2024-05-14', '2024-05-16', 3),
    (19, 95, 'A', '2024-05-10', '2024-05-18', '2024-05-20', 2),
    (20, 80, 'B', '2024-05-12', '2024-05-20', '2024-05-22', 3);


-- 10 records into the course table
INSERT INTO course (courseId, courseCode, courseName)
VALUES
    (1, 'ENG101', 'English Literature'),
    (2, 'MATH202', 'Calculus'),
    (3, 'SCI301', 'Biology'),
    (4, 'HIST401', 'World History'),
    (5, 'COMP502', 'Computer Science'),
    (6, 'ART603', 'Art Appreciation'),
    (7, 'MUS704', 'Music Theory'),
    (8, 'PHYS805', 'Physics'),
    (9, 'GEO906', 'Geography'),
    (10, 'LANG1007', 'Language Arts');

-- 20 records into the student_course table
INSERT INTO student_course (id, studentId, courseId, stdcourse_numeric_grade, stdcourse_letter_grade)
VALUES
    (1, 1, 1, 90, 'A'),
    (2, 2, 2, 85, 'B+'),
    (3, 3, 3, 92, 'A'),
    (4, 4, 4, 88, 'B+'),
    (5, 5, 5, 95, 'A'),
    (6, 6, 6, 85, 'B+'),
    (7, 7, 7, 90, 'A'),
    (8, 8, 8, 94, 'A'),
    (9, 9, 9, 87, 'B+'),
    (10, 10, 10, 93, 'A'),
    (11, 11, 1, null, null),
    (12, 12, 2, null, null),
    (13, 13, 3, null, null),
    (14, 1, 8, 90, 'A'),
    (15, 1, 7, 85, 'B+'),
    (16, 2, 3, 92, 'A'),
    (17, 2, 4, 88, 'B+'),
    (18, 5, 7, 95, 'A'),
    (19, 5, 6, 88, 'B+'),
    (20, 6, 8, 95, 'A');

-- 10 records into the instructor table
INSERT INTO instructor (instructorId, instructorName)
VALUES
    (1, 'Prof. Smith'),
    (2, 'Dr. Johnson'),
    (3, 'Ms. Williams'),
    (4, 'Mr. Brown'),
    (5, 'Prof. Davis'),
    (6, 'Dr. Martinez'),
    (7, 'Ms. Taylor'),
    (8, 'Mr. White'),
    (9, 'Prof. Rodriguez'),
    (10, 'Dr. Wilson');

-- 10 records into the course_instructor table
INSERT INTO course_instructor (id, courseId, instructorId)
VALUES
    (1, 1, 1),
    (2, 2, 2),
    (3, 3, 3),
    (4, 4, 4),
    (5, 5, 5),
    (6, 6, 6),
    (7, 7, 7),
    (8, 8, 8),
    (9, 9, 9),
    (10, 10, 10);


INSERT INTO course_instructor (id, courseId, instructorId)
VALUES
    (11, 1, 2),
    (12, 3, 4),
    (13, 5, 6),
    (14, 7, 8),
    (15, 9, 1);