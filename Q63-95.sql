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
SELECT
    s.studentId,
    s.studentName
FROM
    student s
    JOIN student_course sc ON s.studentId = sc.studentId
    LEFT JOIN (
        SELECT
            sa.studentId,
            ca.courseId
        FROM
            student_assignment sa
            JOIN course_assignment ca ON sa.assignmentId = ca.assignmentId
        GROUP BY
            sa.studentId,
            ca.courseId
    ) submitted ON submitted.studentId = s.studentId
    AND submitted.courseId = sc.courseId
GROUP BY
    s.studentId,
    s.studentName
HAVING
    COUNT(DISTINCT sc.courseId) = COUNT(DISTINCT submitted.courseId);

-- 75) Retrieve the list of students who have not enrolled in any courses.
SELECT
    s.studentId,
    s.studentName
FROM
    student s
WHERE
    s.studentId NOT IN (
        SELECT
            DISTINCT studentId
        FROM
            student_course
    );

-- 76) Retrieve the list of courses that have the highest number of enrolled students.
WITH Num_Enrollees AS (
    SELECT
        courseId,
        COUNT(*) AS Num_Enrollees_In_Course
    FROM
        student_course
    GROUP BY
        courseId
)
SELECT
    ne.courseId,
    c.courseName,
    ne.Num_Enrollees_In_Course
FROM
    course c
    INNER JOIN Num_Enrollees ne ON ne.courseId = c.courseId
WHERE
    ne.Num_Enrollees_In_Course = (
        SELECT
            MAX(Num_Enrollees_In_Course)
        FROM
            Num_Enrollees
    );

-- 77) Retrieve the list of assignments that have the lowest average grade.
WITH Average_Grades AS (
    SELECT
        assignmentId,
        AVG(assignment_numeric_grade) AS Average_Grade
    FROM
        student_assignment
    GROUP BY
        assignmentId
)
SELECT
    ag.assignmentId,
    a.assign_description,
    ag.Average_Grade
FROM
    assignment a
    INNER JOIN Average_Grades ag ON ag.assignmentId = a.assignmentId
WHERE
    ag.Average_Grade = (
        SELECT
            MIN(Average_Grade)
        FROM
            Average_Grades
    );

-- 78) Retrieve the list of students who have submitted all the assignments in a particular
-- course ("assuming course id is 1").
WITH Student_Req_Assignments AS (
    SELECT
        sc.studentId,
        COUNT(*) AS Num_Assignments_Required
    FROM
        student_course sc
        INNER JOIN course_assignment ca ON ca.courseId = sc.courseId
    WHERE
        sc.courseId = 1
    GROUP BY
        sc.studentId
),
Student_Submission_Assignments AS (
    SELECT
        sa.studentId,
        COUNT(*) AS Num_Assignments_Submitted
    FROM
        student_assignment sa
        INNER JOIN course_assignment ca ON ca.assignmentId = sa.assignmentId
    WHERE
        ca.courseId = 1
    GROUP BY
        sa.studentId
)
SELECT
    s.studentId,
    s.studentName
FROM
    student s
    INNER JOIN Student_Req_Assignments sqa ON sqa.studentId = s.studentId
    INNER JOIN Student_Submission_Assignments ssa ON ssa.studentId = sqa.studentId
WHERE
    sqa.Num_Assignments_Required = ssa.Num_Assignments_Submitted;

-- 79) Retrieve the list of courses where the average grade of all students is above 80.
SELECT
    c.courseId,
    c.courseName,
    AVG(stdcourse_numeric_grade) AS Average_Grade
FROM
    course c
    INNER JOIN student_course sc ON sc.courseId = c.courseId
GROUP BY
    courseId
HAVING
    AVG(stdcourse_numeric_grade) > 80;

-- 80) Retrieve the list of students who have the highest grade in each course.
SELECT
    c.courseName,
    s.studentId,
    s.studentName,
    sc.stdcourse_numeric_grade AS Highest_Grade
FROM
    student s
    INNER JOIN student_course sc ON sc.studentId = s.studentId
    INNER JOIN course c ON c.courseId = sc.courseId
WHERE
    (sc.courseId, sc.stdcourse_numeric_grade) IN (
        SELECT
            courseId,
            MAX(stdcourse_numeric_grade) AS Max_Grade_Per_Course
        FROM
            student_course
        GROUP BY
            courseId
    )
ORDER BY
    c.courseName;

-- 81) Retrieve the list of students who have submitted all the assignments on time.
WITH Assignments_Timely_Submitted AS (
    SELECT
        studentId,
        COUNT(*) AS Num_Assignments_On_Time
    FROM
        student_assignment sa
        INNER JOIN assignment a ON a.assignmentId = sa.assignmentId
    WHERE
        sa.assignment_submission_date <= a.assign_due_date
    GROUP BY
        studentId
),
Assignments_Submitted AS (
    SELECT
        studentId,
        COUNT(*) AS Num_Assignments_Submitted
    FROM
        student_assignment
    GROUP BY
        studentId
)
SELECT
    s.studentId,
    s.studentName,
    ats.Num_Assignments_On_Time,
    ass.Num_Assignments_Submitted
FROM
    student s
    INNER JOIN Assignments_Timely_Submitted ats ON ats.studentId = s.studentId
    INNER JOIN Assignments_Submitted ass ON ass.studentId = ats.studentId
WHERE
    ats.Num_Assignments_On_Time = ass.Num_Assignments_Submitted;

-- 82) Retrieve the list of students who have submitted late submissions for any assignment.
SELECT
    DISTINCT s.studentId,
    s.studentName
FROM
    student s
    INNER JOIN student_assignment sa ON sa.studentId = s.studentId
    INNER JOIN assignment a ON a.assignmentId = sa.assignmentId
WHERE
    sa.assignment_submission_date > a.assign_due_date
    OR sa.assignment_submission_date IS NULL;

--COME BACK TO THIS--
-- 83) Retrieve the list of courses that have the lowest average grade for a particular semester.
-- 84) Retrieve the list of students who have not submitted any assignment for a particular
-- course (assuming courseID is 2).
SELECT
    s.studentId,
    s.studentName
FROM
    student s
    INNER JOIN student_course sc ON sc.studentId = s.studentId
WHERE
    courseId = 2
    AND s.studentId NOT IN (
        SELECT
            DISTINCT sa.studentId
        FROM
            student_assignment sa
            INNER JOIN course_assignment ca ON ca.assignmentId = sa.assignmentId
        WHERE
            ca.courseId = 2
            AND sa.assignment_submission_date IS NOT NULL
    );

-- 85) Retrieve the list of courses where the highest grade is less than 90.
WITH Course_Highest_Grade AS (
    SELECT
        courseId,
        MAX(stdcourse_numeric_grade) AS Highest_Grade
    FROM
        student_course
    GROUP BY
        courseId
)
SELECT
    c.courseId,
    c.courseName,
    chg.Highest_Grade
FROM
    course c
    INNER JOIN Course_Highest_Grade chg ON chg.courseId = c.courseId
WHERE
    chg.Highest_Grade < 90;

--COME BACK TO THIS--
-- 86) Retrieve the list of students who have submitted all the assignments, but their average
-- grade is less than 70.
-- 87) Retrieve the list of courses that have at least one student with an average grade of 90 or
-- above.
WITH Student_Average AS (
    SELECT
        studentId,
        AVG(stdcourse_numeric_grade) AS Average_Grade
    FROM
        student_course
    GROUP BY
        studentId
    HAVING
        AVG(stdcourse_numeric_grade) >= 90
)
SELECT
    DISTINCT c.courseId,
    c.courseName
FROM
    course c
    INNER JOIN student_course sc ON sc.courseId = c.courseId
WHERE
    sc.studentId IN (
        SELECT
            studentId
        FROM
            Student_Average
    );

--COME BACK TO THIS--
-- 88) Retrieve the list of students who have not submitted any assignments for any of their
-- enrolled courses.
--COME BACK TO THIS--
-- 89) Retrieve the list of courses that have at least one student who has not submitted any
-- assignments.
--COME BACK TO THIS--
-- 90) Retrieve the list of students who have submitted all the assignments for a particular
-- course.
-- 91) Retrieve the list of assignments that have not been graded yet for a particular course (assuming courseId is 1).
SELECT
    a.assignmentId,
    a.assign_description
FROM
    assignment a
    INNER JOIN student_assignment sa ON sa.assignmentId = a.assignmentId
    INNER JOIN course_assignment ca ON ca.assignmentId = sa.assignmentId
WHERE
    ca.courseId = 1
    AND sa.assignment_graded_date IS NULL;

-- 92) Retrieve the list of students who have not enrolled in any courses.
SELECT
    s.studentId,
    s.studentName
FROM
    student s
WHERE
    s.studentId NOT IN (
        SELECT
            DISTINCT studentId
        FROM
            student_course
    );

-- 93) Retrieve the list of students who have submitted an assignment after the due date.
SELECT
    s.studentId,
    s.studentName
FROM
    student s
    INNER JOIN student_assignment sa ON sa.studentId = s.studentId
    INNER JOIN assignment a ON a.assignmentId = sa.assignmentId
WHERE
    sa.assignment_submission_date > a.assign_due_date;

-- 94) Retrieve the list of courses that have more than 50 enrolled students.
WITH Enrolled_Students_Per_Course AS (
    SELECT
        courseId,
        COUNT(*) AS Num_Students_Enrolled
    FROM
        student_course
    GROUP BY
        courseId
)
SELECT
    c.courseId,
    c.courseName,
    espc.Num_Students_Enrolled
FROM
    course c
    INNER JOIN Enrolled_Students_Per_Course espc ON espc.courseId = c.courseId
WHERE
    espc.Num_Students_Enrolled > 2;

-- 95) Retrieve the list of students who have submitted an assignment for a particular course but
-- have not received a grade yet.
SELECT
    DISTINCT s.studentId,
    studentName
FROM
    student s
    INNER JOIN student_assignment sa ON sa.studentId = s.studentId
WHERE
    assignment_submission_date IS NOT NULL
    AND assignment_graded_date IS NULL;