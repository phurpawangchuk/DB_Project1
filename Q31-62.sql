-- 31) Retrieve the list of students who have submitted all assignments for a specific course.
WITH course_assignments AS (
    SELECT
        ca.assignmentId
    FROM
        course_assignment ca
    WHERE
        ca.courseId = 1
),
assignment_count AS (
    SELECT
        COUNT(*) AS total_assignments
    FROM
        course_assignments
),
student_submissions AS (
    SELECT
        sa.studentId,
        COUNT(sa.assignmentId) AS submitted_assignments
    FROM
        student_assignment sa
        JOIN course_assignments ca ON sa.assignmentId = ca.assignmentId
    GROUP BY
        sa.studentId
),
students_fulfilled AS (
    SELECT
        ss.studentId
    FROM
        student_submissions ss
        JOIN assignment_count ac ON ss.submitted_assignments = ac.total_assignments
)
SELECT
    s.studentId,
    s.studentName,
    s.email
FROM
    students_fulfilled sf
    JOIN student s ON sf.studentId = s.studentId;

-- 32) Retrieve the list of courses that have at least one assignment that no student has submitted.
WITH unsubmitted_assignments AS (
    SELECT
        ca.courseId,
        ca.assignmentId
    FROM
        course_assignment ca
        LEFT JOIN student_assignment sa ON sa.assignmentId = ca.assignmentId
    WHERE
        sa.assignmentId IS NULL
        OR sa.assignment_submission_date IS NULL
)
SELECT
    DISTINCT c.courseId,
    c.courseCode,
    c.courseName
FROM
    unsubmitted_assignments ua
    JOIN course c ON c.courseId = ua.assignmentId;

-- 33) Retrieve the list of students who have submitted the most assignments.
WITH total_student_assignment_count AS (
    SELECT
        sa.studentId,
        COUNT(*) AS student_assignment_count
    FROM
        student_assignment sa
    WHERE
        sa.assignment_submission_date IS NOT NULL
        AND sa.assignment_graded_date IS NOT NULL
        AND sa.assignment_returned_date IS NOT NULL
    GROUP BY
        sa.studentId
    ORDER BY
        student_assignment_count DESC
)
SELECT
    s.studentId,
    s.studentName,
    s.email,
    tsac.student_assignment_count
FROM
    total_student_assignment_count tsac
    JOIN student s ON s.studentId = tsac.studentId
WHERE
    tsac.student_assignment_count = (
        SELECT
            MAX(student_assignment_count)
        FROM
            total_student_assignment_count
    );

-- 34) Retrieve the list of courses that have the highest average grade among students who have
-- submitted all assignments.
WITH -- Get the total number of assignments per course
course_assignments AS (
    SELECT
        ca.courseId,
        ca.assignmentId
    FROM
        course_assignment ca
),
assignment_count AS (
    SELECT
        ca.courseId,
        COUNT(ca.assignmentId) AS total_assignments
    FROM
        course_assignments ca
    GROUP BY
        ca.courseId
),
-- Calculate the number of assignments submitted by each student for each course
student_submissions AS (
    SELECT
        sa.studentId,
        ca.courseId,
        COUNT(sa.assignmentId) AS submitted_assignments
    FROM
        student_assignment sa
        JOIN course_assignment ca ON sa.assignmentId = ca.assignmentId
    GROUP BY
        sa.studentId,
        ca.courseId
),
-- Identify students who have submitted all assignments for their respective courses
students_fulfilled AS (
    SELECT
        ss.studentId,
        ss.courseId
    FROM
        student_submissions ss
        JOIN assignment_count ac ON ss.courseId = ac.courseId
        AND ss.submitted_assignments = ac.total_assignments
),
-- Compute the average grade for each course, considering only students who have submitted all assignments
student_grades AS (
    SELECT
        sf.courseId,
        sc.stdcourse_letter_grade,
        AVG(sc.stdcourse_numeric_grade) AS avg_grade
    FROM
        students_fulfilled sf
        JOIN student_course sc ON sc.studentId = sf.studentId
        AND sc.courseId = sf.courseId
    GROUP BY
        sf.courseId,
        sc.stdcourse_letter_grade
),
-- Retrieve the course(s) with the highest average grade
highest_avg_course AS (
    SELECT
        MAX(avg_grade) AS max_avg_grade
    FROM
        student_grades
) -- Final selection of courses
SELECT
    sg.courseId,
    sg.avg_grade,
    sg.stdcourse_letter_grade,
    c.courseCode,
    c.courseName
FROM
    student_grades sg
    JOIN course c ON c.courseId = sg.courseId
    JOIN highest_avg_course hac ON sg.avg_grade = hac.max_avg_grade;

-- 35) Retrieve the list of courses that have the highest average grade among students who have
-- submitted all assignments.
-- THE SAME WITH 34
-- 36) Retrieve the list of courses with the highest number of enrollments.
WITH course_enrollees AS (
    SELECT
        sc.courseId,
        COUNT(sc.studentId) AS student_count
    FROM
        student_course sc
    GROUP BY
        sc.courseId
)
SELECT
    ce.courseId,
    c.courseCode,
    c.courseName,
    ce.student_count
FROM
    course_enrollees ce
    JOIN course c ON c.courseId = ce.courseId
WHERE
    ce.student_count = (
        SELECT
            MAX(student_count)
        FROM
            course_enrollees
    );

-- 37) Retrieve the list of assignments that have the lowest submission rate.
-- Get the total number of students associated with each assignment through their courses
WITH total_assignments AS (
    SELECT
        ca.assignmentId,
        COUNT(sc.studentId) AS total_students
    FROM
        course_assignment ca
        JOIN student_course sc ON ca.courseId = sc.courseId
    GROUP BY
        ca.assignmentId
),
-- Count the number of submissions for each assignment
submission_counts AS (
    SELECT
        sa.assignmentId,
        COUNT(*) AS submission_count
    FROM
        student_assignment sa
    WHERE
        sa.assignment_submission_date IS NOT NULL
    GROUP BY
        sa.assignmentId
),
-- Calculate the submission rate per assignment
submission_rate AS (
    SELECT
        ta.assignmentId,
        ta.total_students,
        COALESCE(sc.submission_count, 0) AS submission_count,
        (
            COALESCE(sc.submission_count, 0) * 1.0 / ta.total_students
        ) AS submission_rate
    FROM
        total_assignments ta
        LEFT JOIN submission_counts sc ON ta.assignmentId = sc.assignmentId
) -- Retrieve the assignments with the lowest submission rate
SELECT
    sr.assignmentId,
    sr.total_students,
    sr.submission_count,
    sr.submission_rate
FROM
    submission_rate sr
WHERE
    sr.submission_rate = (
        SELECT
            MIN(submission_rate)
        FROM
            submission_rate
    );

-- 38) Retrieve the list of students who have the highest average grade for a specific course.
WITH student_avg_grade AS (
    SELECT
        sc.studentId,
        sc.stdcourse_letter_grade,
        AVG(sc.stdcourse_numeric_grade) AS avg_grade
    FROM
        student_course sc
        JOIN course c ON c.courseId = sc.courseId
    WHERE
        c.courseId = 1
    GROUP BY
        sc.studentId,
        sc.stdcourse_letter_grade
)
SELECT
    s.studentId,
    s.studentName,
    sag.stdcourse_letter_grade,
    sag.avg_grade
FROM
    student_avg_grade sag
    JOIN student s ON s.studentId = sag.studentId
WHERE
    sag.avg_grade = (
        SELECT
            MAX(avg_grade)
        FROM
            student_avg_grade
    );

-- 39) Retrieve the list of courses with the highest percentage of students who have completed all
-- assignments.
WITH course_assignments AS (
    SELECT
        ca.courseId,
        ca.assignmentId
    FROM
        course_assignment ca
),
assignment_count AS (
    SELECT
        ca.courseId,
        COUNT(*) AS total_assignments
    FROM
        course_assignments ca
    GROUP BY
        ca.courseId
),
-- Count the number of assignments each student submitted per course
student_submissions AS (
    SELECT
        sc.courseId,
        sc.studentId,
        COUNT(sa.assignmentId) AS submitted_assignments
    FROM
        student_course sc
        LEFT JOIN student_assignment sa ON sc.studentId = sa.studentId
        JOIN course_assignment ca ON sa.assignmentId = ca.assignmentId
        AND ca.courseId = sc.courseId
    GROUP BY
        sc.courseId,
        sc.studentId
),
-- Identify students who completed all assignments for each course
students_fulfilled AS (
    SELECT
        ss.courseId,
        COUNT(ss.studentId) AS completed_students
    FROM
        student_submissions ss
        JOIN assignment_count ac ON ss.courseId = ac.courseId
        AND ss.submitted_assignments = ac.total_assignments
    GROUP BY
        ss.courseId
),
completion_rate AS (
    SELECT
        sf.courseId,
        sf.completed_students,
        COUNT(sc.studentId) AS total_students,
        (
            sf.completed_students * 100.0 / COUNT(sc.studentId)
        ) AS completion_percentage
    FROM
        students_fulfilled sf
        JOIN student_course sc ON sc.courseId = sf.courseId
    GROUP BY
        sf.courseId
) -- Retrieve courses with the highest completion percentage
SELECT
    cr.courseId,
    cr.completion_percentage,
    c.courseCode,
    c.courseName
FROM
    completion_rate cr
    JOIN course c ON c.courseId = cr.courseId
WHERE
    cr.completion_percentage = (
        SELECT
            MAX(completion_percentage)
        FROM
            completion_rate
    );

-- 40) Retrieve the list of students who have not submitted any assignments for a specific course.
SELECT
    sc.studentId,
    s.studentName
FROM
    student_course sc
    LEFT JOIN student_assignment sa ON sc.studentId = sa.studentId
    LEFT JOIN course_assignment ca ON sc.courseId = ca.courseId
    AND sa.assignmentId = ca.assignmentId
    LEFT JOIN student s ON sc.studentId = s.studentId
WHERE
    sc.courseId = 4
    AND sa.assignmentId IS NULL;

-- 41) Retrieve the list of courses with the lowest average grade.
WITH student_avg_grade AS (
    SELECT
        c.courseId,
        sc.stdcourse_letter_grade,
        AVG(sc.stdcourse_numeric_grade) AS avg_grade
    FROM
        student_course sc
        JOIN course c ON c.courseId = sc.courseId
    GROUP BY
        sc.courseId,
        sc.stdcourse_letter_grade
)
SELECT
    c.courseId,
    c.courseName,
    sag.stdcourse_letter_grade,
    sag.avg_grade
FROM
    student_avg_grade sag
    JOIN course c ON c.courseId = sag.courseId
WHERE
    sag.avg_grade = (
        SELECT
            MAX(avg_grade)
        FROM
            student_avg_grade
    );

-- 42) Retrieve the list of assignments that have the highest average grade.
-- 43) Retrieve the list of students who have the highest overall grade across all courses.
-- 44) Retrieve the list of assignments that have not been graded yet.
-- 45) Retrieve the list of courses that have not been assigned any assignments yet.
-- 46) Retrieve the list of students who have completed all assignments for a specific course.
-- 47) Retrieve the list of students who have submitted all assignments but have not received a passing
-- grade for a specific course.
-- 48) Retrieve the list of courses that have the highest percentage of students who have received a
-- passing grade.
-- 49) Retrieve the list of students who have submitted assignments late for a specific course.
-- 50) Retrieve the list of courses that have the highest percentage of students who have dropped
-- out.
-- 51) Retrieve the list of students who have not yet submitted any assignments for a specific
-- course.
-- 52) Retrieve the list of students who have submitted at least one assignment for a specific
-- course but have not completed all assignments.
-- 53) Retrieve the list of assignments that have received the highest average grade.
-- 54) Retrieve the list of students who have received the highest average grade across all
-- courses.
-- 55) Retrieve the list of courses that have the highest average grade.
-- 56) Retrieve the list of courses that have at least one student enrolled but no assignments
-- have been created yet.
-- 57) Retrieve the list of courses that have at least one assignment created but no student has
-- enrolled yet.
-- 58) Retrieve the list of students who have submitted all assignments for a specific course.
-- 59) Retrieve the list of courses where the overall average grade is higher than the average
-- grade of a specific student.
-- 60) Retrieve the list of students who have not yet submitted any assignments for any course.
-- 61) Retrieve the list of students who have completed all the courses they have enrolled in.
-- 62) Retrieve the list of courses where the average grade is lower than a specific threshold.