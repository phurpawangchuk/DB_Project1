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
WITH assignment_grades AS (
    SELECT
        sa.assignmentId,
        sa.assignment_letter_grade,
        AVG(sa.assignment_numeric_grade) AS avg_grade
    FROM
        student_assignment sa
    GROUP BY
        sa.assignmentId,
        sa.assignment_letter_grade
)
SELECT
    ag.assignmentId,
    a.assign_description,
    a.assign_due_date,
    ag.avg_grade,
    ag.assignment_letter_grade
FROM
    assignment_grades ag
    JOIN assignment a ON ag.assignmentId = a.assignmentId
WHERE
    ag.avg_grade = (
        SELECT
            MAX(avg_grade)
        FROM
            assignment_grades
    );

-- 43) Retrieve the list of students who have the highest overall grade across all courses.
WITH student_total_grades AS (
    SELECT
        sc.studentId,
        SUM(sc.stdcourse_numeric_grade) AS total_grade
    FROM
        student_course sc
    GROUP BY
        sc.studentId
    HAVING
        total_grade IS NOT NULL
)
SELECT
    s.studentId,
    s.studentName,
    stg.total_grade
FROM
    student_total_grades stg
    JOIN student s ON stg.studentId = s.studentId
WHERE
    stg.total_grade = (
        SELECT
            MAX(total_grade)
        FROM
            student_total_grades
    );

-- 44) Retrieve the list of assignments that have not been graded yet.
SELECT
    a.assignmentId,
    a.assign_description,
    a.assign_due_date
FROM
    student_assignment sa
    LEFT JOIN assignment a ON a.assignmentId = sa.assignmentId
WHERE
    sa.assignment_submission_date IS NULL
    AND assignment_returned_date IS NULL
    AND assignment_graded_date IS NULL;

-- 45) Retrieve the list of courses that have not been assigned any assignments yet.
SELECT
    *
FROM
    course c
WHERE
    c.courseId NOT IN (
        SELECT
            courseId
        FROM
            course_assignment
    );

-- 46) Retrieve the list of students who have completed all assignments for a specific course.
-- courses.
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

-- 47) Retrieve the list of students who have submitted all assignments but have not received a passing
-- grade for a specific course.
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
students_failed_fulfilled AS (
    SELECT
        ss.studentId,
        sc.stdcourse_numeric_grade,
        sc.stdcourse_letter_grade
    FROM
        student_submissions ss
        JOIN assignment_count ac ON ss.submitted_assignments = ac.total_assignments
        JOIN student_course sc ON sc.studentId = ss.studentId
    WHERE
        sc.courseId = 1
        AND sc.stdcourse_numeric_grade < 62
        AND sc.stdcourse_letter_grade = 'F'
)
SELECT
    s.studentId,
    s.studentName,
    s.email,
    sff.stdcourse_numeric_grade,
    sff.stdcourse_letter_grade
FROM
    students_failed_fulfilled sff
    JOIN student s ON sff.studentId = s.studentId;

-- 48) Retrieve the list of courses that have the highest percentage of students who have received a
-- passing grade.
WITH total_students AS (
    SELECT
        courseId,
        COUNT(*) AS total
    FROM
        student_course
    GROUP BY
        courseId
),
passed_students AS (
    SELECT
        sc.courseId,
        COUNT(*) AS total_passed_students
    FROM
        student_course sc
    WHERE
        sc.stdcourse_numeric_grade >= 62
        AND NOT sc.stdcourse_letter_grade = 'F'
    GROUP BY
        sc.courseId
),
pass_rates AS (
    SELECT
        ts.courseId,
        c.courseName,
        c.courseCode,
        COALESCE(
            CAST(ps.total_passed_students AS FLOAT) / ts.total,
            0
        ) AS pass_rate
    FROM
        total_students ts
        LEFT JOIN passed_students ps ON ts.courseId = ps.courseId
        JOIN course c ON c.courseId = ps.courseId
    GROUP BY
        ts.courseId
)
SELECT
    pr.courseId,
    c.courseCode,
    c.courseName
FROM
    pass_rates pr
    JOIN course c ON pr.courseId = c.courseId
WHERE
    pr.pass_rate = (
        SELECT
            MAX(pass_rate)
        FROM
            pass_rates
    );

-- 49) Retrieve the list of students who have submitted assignments late for a specific course.
SELECT
    sa.studentId,
    s.studentName,
    ca.courseId,
    ca.assignmentId,
    a.assign_due_date,
    sa.assignment_submission_date
FROM
    student_assignment sa
    JOIN assignment a ON a.assignmentId = sa.assignmentId
    JOIN course_assignment ca ON ca.assignmentId = sa.assignmentId
    AND ca.courseId = 1
    JOIN student s ON s.studentId = sa.studentId
WHERE
    a.assign_due_date < sa.assignment_submission_date
    AND ca.courseId = 1;

-- 50) Retrieve the list of courses that have the highest percentage of students who have dropped
-- out.
WITH students_dropped_list AS (
    SELECT
        sc.courseId,
        COUNT(sc.is_active) AS drop_count
    FROM
        student_course sc
    GROUP BY
        sc.courseId
)
SELECT
    sdl.courseId,
    c.courseCode,
    c.courseName,
    sdl.drop_count
FROM
    students_dropped_list sdl
    JOIN course c ON sdl.courseId = c.courseId
WHERE
    sdl.drop_count = (
        SELECT
            MAX(drop_count)
        FROM
            students_dropped_list
    );

-- 51) Retrieve the list of students who have not yet submitted any assignments for a specific
-- course.
SELECT
    s.studentId,
    s.studentName
FROM
    student s
WHERE
    s.studentId IN (
        SELECT
            studentId
        FROM
            student_course
        WHERE
            courseId = 1
    )
    AND s.studentId NOT IN (
        SELECT
            sa.studentId
        FROM
            student_assignment sa
            JOIN course_assignment ca ON sa.assignmentId = ca.assignmentId
        WHERE
            ca.courseId = 1
    );

-- 52) Retrieve the list of students who have submitted at least one assignment for a specific
-- course but have not completed all assignments.
WITH assignment_count AS (
    SELECT
        ca.courseId,
        COUNT(*) AS total_assignments
    FROM
        course_assignment ca
    WHERE
        ca.courseId = 1
    GROUP BY
        ca.courseId
),
student_submissions AS (
    SELECT
        sc.courseId,
        sc.studentId,
        COUNT(sa.assignmentId) AS submitted_assignments
    FROM
        student_course sc
        LEFT JOIN student_assignment sa ON sc.studentId = sa.studentId
        JOIN course_assignment ca ON sa.assignmentId = ca.assignmentId
        AND ca.courseId = 1
    GROUP BY
        sc.studentId,
        sc.courseId
)
SELECT
    ss.studentId,
    s.studentName
FROM
    student_submissions ss
    JOIN assignment_count ac ON ac.courseId = ss.courseId
    JOIN student s ON s.studentId = ss.studentId
WHERE
    ss.submitted_assignments >= 1
    AND NOT ac.total_assignments = ss.submitted_assignments;

-- 53) Retrieve the list of assignments that have received the highest average grade.
WITH assignments_with_avg AS (
    SELECT
        sa.assignmentId,
        sa.assignment_letter_grade,
        AVG(sa.assignment_numeric_grade) AS avg_grade
    FROM
        student_assignment sa
    GROUP BY
        sa.assignmentId,
        sa.assignment_letter_grade
)
SELECT
    a.assignmentId,
    a.assign_description,
    a.assign_due_date,
    awa.avg_grade,
    awa.assignment_letter_grade
FROM
    assignments_with_avg awa
    JOIN assignment a ON awa.assignmentId = a.assignmentId
WHERE
    awa.avg_grade = (
        SELECT
            MAX(avg_grade)
        FROM
            assignments_with_avg
    );

-- 54) Retrieve the list of students who have received the highest average grade across all
-- courses.
WITH students_with_avg AS (
    SELECT
        sc.studentId,
        sc.stdcourse_letter_grade,
        AVG(sc.stdcourse_numeric_grade) AS avg_grade
    FROM
        student_course sc
    GROUP BY
        sc.studentId,
        sc.stdcourse_letter_grade
)
SELECT
    s.studentId,
    s.studentName,
    swa.avg_grade,
    swa.stdcourse_letter_grade
FROM
    students_with_avg swa
    JOIN student s ON s.studentId = swa.studentId
WHERE
    swa.avg_grade = (
        SELECT
            MAX(avg_grade)
        FROM
            students_with_avg
    );

-- 55) Retrieve the list of courses that have the highest average grade.
WITH courses_with_avg AS (
    SELECT
        sc.courseId,
        sc.stdcourse_letter_grade,
        AVG(sc.stdcourse_numeric_grade) AS avg_grade
    FROM
        student_course sc
    GROUP BY
        sc.courseId,
        sc.stdcourse_letter_grade
)
SELECT
    c.courseId,
    c.courseCode,
    c.courseName,
    swa.avg_grade,
    swa.stdcourse_letter_grade
FROM
    students_with_avg swa
    JOIN course c ON c.courseId = swa.courseId
WHERE
    swa.avg_grade = (
        SELECT
            MAX(avg_grade)
        FROM
            students_with_avg
    );

-- 56) Retrieve the list of courses that have at least one student enrolled but no assignments
-- have been created yet.
WITH course_enrollees AS (
    SELECT
        sc.courseId,
        COUNT(sc.studentId) AS student_count
    FROM
        student_course sc
    GROUP BY
        sc.courseId
    HAVING
        student_count >= 1
)
SELECT
    c.courseId,
    c.courseCode,
    c.courseName
FROM
    course_enrollees ce
    JOIN course c ON c.courseId = ce.courseId
WHERE
    ce.courseId NOT IN (
        SELECT
            courseId
        FROM
            course_assignment
    );

-- 57) Retrieve the list of courses that have at least one assignment created but no student has
-- enrolled yet.
SELECT
    c.courseId,
    c.courseCode,
    c.courseName
FROM
    course c
WHERE
    c.courseId IN (
        SELECT
            ca.courseId
        FROM
            course_assignment ca
        GROUP BY
            ca.courseId
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            student_course sc
        WHERE
            sc.courseId = c.courseId
    );

-- 58) Retrieve the list of students who have submitted all assignments for a specific course.
-- Duplicate for 31
-- 59) Retrieve the list of courses where the overall average grade is higher than the average
-- grade of a specific student.
SELECT
    sc.courseId,
    AVG(sc.stdcourse_numeric_grade) AS avg_grade
FROM
    student_course sc
WHERE
    avg_grade > (
        SELECT
            AVG(sc.stdcourse_numeric_grade)
        FROM
            student_course sc
        WHERE
            sc.studentId = 1
    );

-- 60) Retrieve the list of students who have not yet submitted any assignments for any course.
SELECT
    s.studentId,
    s.studentName
FROM
    student s
WHERE
    s.studentId NOT IN (
        SELECT
            studentId
        FROM
            student_assignment
    );

-- 61) Retrieve the list of students who have completed all the courses they have enrolled in.
SELECT
    DISTINCT s.studentId,
    s.studentName
FROM
    student_course sc
    JOIN student s ON sc.studentId = s.studentId
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            student_course sc
        WHERE
            sc.studentId = s.studentId
            AND (
                sc.stdcourse_numeric_grade IS NULL
                OR sc.stdcourse_letter_grade = 'F'
            )
    );

-- 62) Retrieve the list of courses where the average grade is lower than a specific threshold.
WITH courses_with_avg AS (
    SELECT
        sc.courseId,
        AVG(sc.stdcourse_numeric_grade) AS avg_grade
    FROM
        student_course sc
    GROUP BY
        sc.courseId
    HAVING
        avg_grade < 80
)
SELECT
    c.courseId,
    c.courseCode,
    c.courseName,
    cwa.avg_grade
FROM
    courses_with_avg cwa
    JOIN course c ON cwa.courseId = c.courseId;