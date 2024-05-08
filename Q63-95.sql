-- 63) Retrieve the list of courses where the number of students enrolled is less than a specific
-- threshold (Assuming the threshold is 10).
SELECT
    c.courseId,
    c.courseCode,
    c.courseName,
    COUNT(sc.courseId) AS Students_Enrolled
FROM
    course c
    LEFT JOIN student_course sc ON sc.courseId = c.courseId
GROUP BY
    c.courseId
HAVING
    COUNT(sc.courseId) < 10;

-- 64) Retrieve the list of students who have not completed a specific course (Assuming courseId is 1) but have submitted
-- all the assignments for that course.
--We are also displaying the number of assignments the student has submitted and grouping them by studentId and studentName
WITH Student_Not_Completed AS (
    SELECT
        studentId
    FROM
        student_course
    WHERE
        courseId = 1
        AND stdcourse_numeric_grade IS NULL
        AND stdcourse_letter_grade IS NULL
),
Course_Assignments AS(
    SELECT
        assignmentId
    FROM
        course_assignment
    WHERE
        courseId = 1
)
SELECT
    snc.studentId,
    s.studentName,
    Count(*) AS Num_Assignments_Submitted
FROM
    student s
    INNER JOIN Student_Not_Completed snc ON snc.studentId = s.studentId
    INNER JOIN Course_Assignments ca ON 1 = 1 --This is to join each resulting table with each course assignment like a cartesian join
WHERE
    (snc.studentId, ca.assignmentId) IN (
        SELECT
            studentId,
            assignmentId
        FROM
            student_assignment
    )
GROUP BY
    snc.studentId,
    s.studentName;

-- 65) Retrieve the list of courses where the average grade is higher than the overall average
-- grade of all courses.
SELECT
    sc.courseId,
    c.courseName,
    AVG(stdcourse_numeric_grade) AS Average_Per_Course
FROM
    course c
    INNER JOIN student_course sc ON sc.courseId = c.courseId
GROUP BY
    sc.courseId,
    c.courseName
HAVING
    AVG(stdcourse_numeric_grade) > (
        SELECT
            AVG(stdcourse_numeric_grade)
        FROM
            student_course
    );

--Another way to do it using WITH
WITH Overall_Average AS (
    SELECT
        AVG(stdcourse_numeric_grade) AS overall
    FROM
        student_course
)
SELECT
    sc.courseId,
    c.courseName,
    AVG(stdcourse_numeric_grade) AS Average_Per_Course
FROM
    course c
    INNER JOIN student_course sc ON sc.courseId = c.courseId
    INNER JOIN Overall_Average oa ON 1 = 1
GROUP BY
    sc.courseId,
    c.courseName,
    oa.overall
HAVING
    AVG(stdcourse_numeric_grade) > oa.overall;

-- 66) Retrieve the list of courses where the average grade is higher than a specific threshold (Assuming it is 85)
-- and the number of students enrolled is greater than a specific threshold.
SELECT
    sc.courseId,
    c.courseName,
    COUNT(*) AS Num_Enrollees,
    AVG(stdcourse_numeric_grade) AS Average_Per_Course
FROM
    course c
    INNER JOIN student_course sc ON sc.courseId = c.courseId
GROUP BY
    sc.courseId,
    c.courseName
HAVING
    AVG(stdcourse_numeric_grade) > 0
    AND COUNT(*) > 1;

-- 67) Retrieve the list of students who have enrolled in at least two courses and have not
-- submitted any assignments in the past month.
WITH Student_With_Multiple_Courses AS (
    SELECT
        s.studentId,
        s.studentName,
        COUNT(*) AS Num_Courses_Enrolled
    FROM
        student s
        INNER JOIN student_course sc ON sc.studentId = s.studentId
    GROUP BY
        s.studentId
    HAVING
        COUNT(*) >= 2
)
SELECT
    swmp.studentId,
    swmp.studentName,
    swmp.Num_Courses_Enrolled
FROM
    Student_With_Multiple_Courses swmp
WHERE
    swmp.studentId NOT IN (
        SELECT
            studentId
        FROM
            student_assignment
        WHERE
            MONTH(assignment_submission_date) = MONTH(CURDATE() - INTERVAL 1 MONTH)
    );

--COME BACK TO THIS---
-- 68) Retrieve the list of courses where the percentage of students who have submitted all the
-- assignments is higher than a specific threshold.
-- 69) Retrieve the list of students who have enrolled in a course but have not submitted any
-- assignments.
SELECT
    s.studentId,
    s.studentName
FROM
    student s
    INNER JOIN student_course sc ON sc.studentId = s.studentId
WHERE
    s.studentId NOT IN (
        SELECT
            studentId
        FROM
            student_assignment
    );

--COME BACK TO THIS---
-- 70) Retrieve the list of courses where the percentage of students who have submitted at least
-- one assignment is lower than a specific threshold.
-- 71) Retrieve the list of students who have submitted an assignment after the due date.
SELECT
    s.studentId,
    s.studentName,
    COUNT(*) AS Num_Late_Submissions
FROM
    student s
    INNER JOIN student_assignment sa ON sa.studentId = s.studentId
    INNER JOIN assignment a ON a.assignmentId = sa.assignmentId
WHERE
    sa.assignment_submission_date > assign_due_date
GROUP BY
    s.studentId,
    s.studentName;

-- 72) Retrieve the list of courses where the average grade of female students is higher than that
-- of male students.
SELECT
    s.gender,
    AVG(sc.stdcourse_numeric_grade) AS Average_Grade
FROM
    student s
    INNER JOIN student_course sc ON sc.studentId = s.studentId
GROUP BY
    s.gender;

WITH Female_Count AS (
    SELECT
        sc.courseId,
        COUNT(*) AS Female_Number
    FROM
        student s
        INNER JOIN student_course sc ON sc.studentId = s.studentId
    WHERE
        s.gender = 'F'
    GROUP BY
        sc.courseId,
        s.gender
),
Male_Count AS(
    SELECT
        sc.courseId,
        COUNT(*) AS Male_Number
    FROM
        student s
        INNER JOIN student_course sc ON sc.studentId = s.studentId
    WHERE
        s.gender = 'M'
    GROUP BY
        sc.courseId,
        s.gender
)
SELECT
    c.courseId,
    c.courseName,
    fc.Female_Number,
    mc.Male_Number
FROM
    course c
    LEFT JOIN Female_Count fc ON fc.courseId = c.courseId
    LEFT JOIN Male_Count mc ON mc.courseId = c.courseId
WHERE
    fc.Female_Number >= 1
    AND mc.Male_Number IS NULL;

-- 74) Retrieve the list of students who have submitted at least one assignment in all the courses
-- they are enrolled in.
-- 75) Retrieve the list of students who have not enrolled in any courses.
-- 76) Retrieve the list of courses that have the highest number of enrolled students.
-- 77) Retrieve the list of assignments that have the lowest average grade.
-- 78) Retrieve the list of students who have submitted all the assignments in a particular
-- course.
-- 79) Retrieve the list of courses where the average grade of all students is above 80.
-- 80) Retrieve the list of students who have the highest grade in each course.
-- 81) Retrieve the list of students who have submitted all the assignments on time.
-- 82) Retrieve the list of students who have submitted late submissions for any assignment.
-- 83) Retrieve the list of courses that have the lowest average grade for a particular semester.
-- 84) Retrieve the list of students who have not submitted any assignment for a particular
-- course.
-- 85) Retrieve the list of courses where the highest grade is less than 90.
-- 86) Retrieve the list of students who have submitted all the assignments, but their average
-- grade is less than 70.
-- 87) Retrieve the list of courses that have at least one student with an average grade of 90 or
-- above.
-- 88) Retrieve the list of students who have not submitted any assignments for any of their
-- enrolled courses.
-- 89) Retrieve the list of courses that have at least one student who has not submitted any
-- assignments.
-- 90) Retrieve the list of students who have submitted all the assignments for a particular
-- course.
-- 91) Retrieve the list of assignments that have not been graded yet for a particular course.
-- 92) Retrieve the list of students who have not enrolled in any courses.
-- 93) Retrieve the list of students who have submitted an assignment after the due date.
-- 94) Retrieve the list of courses that have more than 50 enrolled students.
-- 95) Retrieve the list of students who have submitted an assignment for a particular course but
-- have not received a grade yet.