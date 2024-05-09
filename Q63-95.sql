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

-- 68) Retrieve the list of courses where the percentage of students who have submitted all the
-- assignments is higher than a specific threshold (49%).
WITH Assignments_Required AS (
    SELECT
        sc.studentId,
        sc.courseId,
        COUNT(*) AS Num_Assignments_Required
    FROM
        student_course sc
        INNER JOIN course_assignment ca ON ca.courseId = sc.courseId
    GROUP BY
        sc.studentId,
        sc.courseId
),
Assignments_Submitted AS(
    SELECT
        sa.studentId,
        ca.courseId,
        COUNT(*) AS Num_Assignments_Submitted
    FROM
        student_assignment sa
        INNER JOIN course_assignment ca ON ca.assignmentId = sa.assignmentId
    WHERE
        sa.assignment_submission_date IS NOT NULL
    GROUP BY
        sa.studentId,
        ca.courseId
),
Joined_Required_Submitted AS (
    SELECT
        ar.studentId,
        ar.courseId,
        ar.Num_Assignments_Required,
        ass.Num_Assignments_Submitted
    FROM
        Assignments_Required ar
        LEFT JOIN Assignments_Submitted ass ON ass.studentId = ar.studentId
        AND ass.courseId = ar.courseId
),
Total_Students_Per_Course AS (
    SELECT
        jrs.courseId,
        COUNT(*) AS Total_Enrolled_Students
    FROM
        Joined_Required_Submitted jrs
    GROUP BY
        jrs.courseId
),
Total_Students_Submitted_Per_Course AS (
    SELECT
        jrs.courseId,
        COUNT(*) AS Total_Enrolled_Students_Who_Submitted_All
    FROM
        Joined_Required_Submitted jrs
    WHERE
        jrs.Num_Assignments_Required = jrs.Num_Assignments_Submitted
    GROUP BY
        jrs.courseId
),
Total_Enrolled_AND_Total_Submitted AS (
    SELECT
        tspc.courseId,
        tspc.Total_Enrolled_Students,
        tsspc.Total_Enrolled_Students_Who_Submitted_All
    FROM
        Total_Students_Per_Course tspc
        LEFT JOIN Total_Students_Submitted_Per_Course tsspc ON tsspc.courseId = tspc.courseId
)
SELECT
    c.courseId,
    c.courseName
FROM
    course c
    INNER JOIN Total_Enrolled_AND_Total_Submitted teats ON teats.courseId = c.courseId
WHERE
    (
        teats.Total_Enrolled_Students_Who_Submitted_All / teats.Total_Enrolled_Students * 100
    ) > 49;

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

-- 70) Retrieve the list of courses where the percentage of students who have submitted at least
-- one assignment is lower than a specific threshold. (49%).
WITH Assignments_Submitted AS(
    SELECT
        sa.studentId,
        ca.courseId,
        COUNT(*) AS Num_Assignments_Submitted
    FROM
        student_assignment sa
        INNER JOIN course_assignment ca ON ca.assignmentId = sa.assignmentId
    WHERE
        sa.assignment_submission_date IS NOT NULL
    GROUP BY
        sa.studentId,
        ca.courseId
),
Total_Students_Per_Course AS (
    SELECT
        sc.courseId,
        COUNT(*) AS Total_Enrolled_Students
    FROM
        student_course sc
    GROUP BY
        sc.courseId
),
Course_With_Students_Submitted_At_Least_One AS (
    SELECT
        ass.courseId,
        COUNT(*) AS Num_Students_Who_Submitted_At_Least_One
    FROM
        Assignments_Submitted ass
    WHERE
        ass.Num_Assignments_Submitted >= 1
    GROUP BY
        ass.courseId
),
Total_Enrolled_AND_Total_Submitted_At_Least_One AS (
    SELECT
        tspc.courseId,
        tspc.Total_Enrolled_Students,
        cswssato.Num_Students_Who_Submitted_At_Least_One
    FROM
        Total_Students_Per_Course tspc
        LEFT JOIN Course_With_Students_Submitted_At_Least_One cswssato ON cswssato.courseId = tspc.courseId
)
SELECT
    c.courseId,
    c.courseName
FROM
    course c
    INNER JOIN Total_Enrolled_AND_Total_Submitted_At_Least_One teatsalo ON teatsalo.courseId = c.courseId
WHERE
    (
        teatsalo.Num_Students_Who_Submitted_At_Least_One / teatsalo.Total_Enrolled_Students * 100
    ) < 49;

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

-- 83) Retrieve the list of courses that have the lowest average grade for a particular semester (assuming this is semester 1).
WITH Average_Grade_For_Semester AS (
    SELECT
        courseId,
        AVG(stdcourse_numeric_grade) AS Average_Grade_For_Sem
    FROM
        student_course
    WHERE
        semester = 1
    GROUP BY
        courseId
)
SELECT
    agfs.courseId,
    c.courseName
FROM
    course c
    INNER JOIN Average_Grade_For_Semester agfs ON agfs.courseId = c.courseId
WHERE
    agfs.Average_Grade_For_Sem = (
        SELECT
            MIN(Average_Grade_For_Sem)
        FROM
            Average_Grade_For_Semester
    );

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

-- 86) Retrieve the list of students who have submitted all the assignments, but their average
-- grade is less than 70.
WITH All_Assignments_Submitted AS (
    SELECT
        sa.studentId
    FROM
        student_assignment sa
        JOIN course_assignment ca ON sa.assignmentId = ca.assignmentId
    GROUP BY
        sa.studentId
    HAVING
        COUNT(DISTINCT ca.assignmentId) = (
            SELECT
                COUNT(DISTINCT assignmentId)
            FROM
                course_assignment
        )
),
Student_Average_Grades AS (
    SELECT
        studentId,
        AVG(assignment_numeric_grade) AS avgGrade
    FROM
        student_assignment
    GROUP BY
        studentId
    HAVING
        AVG(assignment_numeric_grade) < 70
)
SELECT
    s.studentId,
    s.studentName
FROM
    student s
    JOIN All_Assignments_Submitted aas ON s.studentId = aas.studentId
    JOIN Student_Average_Grades sag ON s.studentId = sag.studentId;

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

-- 88) Retrieve the list of students who have not submitted any assignments for any of their
-- enrolled courses.
WITH Assignments_Submitted AS (
    SELECT
        sa.studentId,
        ca.courseId,
        COUNT(*) AS Num_Assignments_Submitted
    FROM
        student_assignment sa
        INNER JOIN course_assignment ca ON ca.assignmentId = sa.assignmentId
    WHERE
        sa.assignment_submission_date IS NOT NULL
    GROUP BY
        sa.studentId,
        ca.courseId
),
Total_Assignments_Per_Enrolled_Student AS (
    SELECT
        s.studentId,
        SUM(ass.Num_Assignments_Submitted) AS Total_Assignments_Submitted_Per_Student
    FROM
        student s
        INNER JOIN student_course sc ON sc.studentId = s.studentId
        LEFT JOIN Assignments_Submitted ass ON ass.studentId = sc.studentId
        AND ass.courseId = sc.courseId
    GROUP BY
        s.studentId
)
SELECT
    tapes.studentId,
    s.studentName
FROM
    student s
    INNER JOIN Total_Assignments_Per_Enrolled_Student tapes ON tapes.studentId = s.studentId
WHERE
    tapes.Total_Assignments_Submitted_Per_Student IS NULL;

-- 89) Retrieve the list of courses that have at least one student who has not submitted any
-- assignments.
WITH Assignments_Submitted AS (
    SELECT
        sa.studentId,
        ca.courseId,
        COUNT(*) AS Num_Assignments_Submitted
    FROM
        student_assignment sa
        INNER JOIN course_assignment ca ON ca.assignmentId = sa.assignmentId
    WHERE
        sa.assignment_submission_date IS NOT NULL
    GROUP BY
        sa.studentId,
        ca.courseId
),
Num_Assignments_Per_Student_Per_Course AS (
    SELECT
        s.studentId,
        sc.courseId,
        ass.Num_Assignments_Submitted
    FROM
        student s
        INNER JOIN student_course sc ON sc.studentId = s.studentId
        LEFT JOIN Assignments_Submitted ass ON ass.studentId = sc.studentId
        AND ass.courseId = sc.courseId
)
SELECT
    DISTINCT nampspc.courseId,
    c.courseName
FROM
    course c
    INNER JOIN Num_Assignments_Per_Student_Per_Course nampspc ON nampspc.courseId = c.courseId
WHERE
    nampspc.Num_Assignments_Submitted IS NULL;

-- 90) Retrieve the list of students who have submitted all the assignments for a particular
-- course(assuming courseId is 1).
WITH Num_Submission_Of_Student_For_Course AS (
    SELECT
        sa.studentId,
        ca.courseId,
        COUNT(*) AS Num_Submissions_For_Course
    FROM
        student_assignment sa
        INNER JOIN course_assignment ca ON ca.assignmentId = sa.assignmentId
    WHERE
        ca.courseId = 1
        AND sa.assignment_submission_date IS NOT NULL
    GROUP BY
        sa.studentId,
        ca.courseId
)
SELECT
    s.studentId,
    s.studentName
FROM
    student s
    INNER JOIN Num_Submission_Of_Student_For_Course nsosfc ON nsosfc.studentId = s.studentId
WHERE
    nsosfc.Num_Submissions_For_Course = (
        SELECT
            COUNT(*)
        FROM
            course_assignment
        WHERE
            courseId = 1
        GROUP BY
            courseId
    );

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