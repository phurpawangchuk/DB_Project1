-- 1) Retrieve the list of all students who have enrolled in a specific course.
    SELECT studentName,courseName
    FROM student s
    INNER JOIN student_course sc ON sc.studentId=s.studentId
    INNER JOIN course c ON c.courseId=sc.courseId
    WHERE courseName='Computer Science'

    +---------------+------------------+
    | studentName   | courseName       |
    +---------------+------------------+
    | Michael Davis | Computer Science |
    +---------------+------------------+
    1 row in set (0.00 sec)

-- 2) Retrieve the average grade of a specific assignment across all students.
    SELECT studentName,avg(assignment_numeric_grade) as averageGrade
    FROM student_assignment sa
    INNER JOIN student s ON s.studentId=sa.studentId
    WHERE assignmentId=1
    GROUP BY studentName

    +-------------+--------------+
    | studentName | averageGrade |
    +-------------+--------------+
    | John Doe    |      85.0000 |
    +-------------+--------------+
    1 row in set (0.00 sec)

-- 3) Retrieve the list of all courses taken by a specific student.
    SELECT courseName,studentName
    FROM student_course sc
    INNER JOIN student s ON s.studentId = sc.studentId
    INNER JOIN course c ON c.courseId = sc.courseId
    WHERE s.studentId=1;

    +--------------------+-------------+
    | courseName         | studentName |
    +--------------------+-------------+
    | English Literature | John Doe    |
    | Music Theory       | John Doe    |
    | Physics            | John Doe    |
    +--------------------+-------------+
    3 rows in set (0.00 sec)

-- 4) Retrieve the list of all instructors who teach a specific course.
    SELECT instructorName,courseName
    FROM course_instructor ci
    INNER JOIN course c ON c.courseId=ci.courseId
    INNER JOIN instructor i ON i.instructorId=ci.instructorId
    WHERE c.courseId = 1;

    +----------------+--------------------+
    | instructorName | courseName         |
    +----------------+--------------------+
    | Prof. Smith    | English Literature |
    | Dr. Johnson    | English Literature |
    +----------------+--------------------+
    2 rows in set (0.01 sec)

-- 5) Retrieve the total number of students enrolled in a specific course.
    SELECT courseName,count(*) as Total_std
    FROM student s
    INNER JOIN student_course sc ON sc.studentId=s.studentId
    INNER JOIN course c ON c.courseId=sc.courseId
    GROUP BY courseName;

    +--------------------+-----------+
    | courseName         | Total_std |
    +--------------------+-----------+
    | English Literature |         2 |
    | Calculus           |         2 |
    | Biology            |         3 |
    | World History      |         2 |
    | Computer Science   |         1 |
    | Art Appreciation   |         2 |
    | Music Theory       |         3 |
    | Physics            |         3 |
    | Geography          |         1 |
    | Language Arts      |         1 |
    +--------------------+-----------+
    10 rows in set (0.02 sec)

-- 6) Retrieve the list of all assignments for a specific course.
    SELECT a.assignmentId,c.courseName
    FROM assignment a
    INNER JOIN course_assignment ca ON ca.assignmentId=a.assignmentId
    INNER JOIN course c ON c.courseId=ca.courseId
    WHERE courseName='Computer Science';
    +--------------+------------------+
    | assignmentId | courseName       |
    +--------------+------------------+
    |            3 | Computer Science |
    |            4 | Computer Science |
    |            5 | Computer Science |
    +--------------+------------------+
    3 rows in set (0.00 sec)

-- 7) Retrieve the highest grade received by a specific student in a specific course.
    SELECT s.studentId,c.courseId,max(stdcourse_numeric_grade) as MaxGrade
    FROM student s
    INNER JOIN student_course sc ON sc.studentId=s.studentId
    INNER JOIN course c ON c.courseId= sc.courseId
    GROUP BY s.studentId,c.courseId
    ORDER BY MaxGrade DESC;

    +-----------+----------+----------+
    | studentId | courseId | MaxGrade |
    +-----------+----------+----------+
    |         5 |        5 |       95 |
    |         5 |        7 |       95 |
    |         6 |        8 |       95 |
    |         8 |        8 |       94 |
    |        10 |       10 |       93 |
    |         2 |        3 |       92 |
    |         3 |        3 |       92 |
    |         1 |        1 |       90 |
    |         1 |        8 |       90 |
    |         7 |        7 |       90 |
    |         2 |        4 |       88 |
    |         4 |        4 |       88 |
    |         5 |        6 |       88 |
    |         9 |        9 |       87 |
    |         1 |        7 |       85 |
    |         6 |        6 |       85 |
    |         2 |        2 |       85 |
    |        11 |        1 |     NULL |
    |        12 |        2 |     NULL |
    |        13 |        3 |     NULL |
    +-----------+----------+----------+
    20 rows in set (0.00 sec)

-- 8) Retrieve the list of all students who have not completed a specific assignment.
    SELECT studentName,sa.assignmentId
    FROM student s
    INNER JOIN student_assignment sa ON sa.studentId=s.studentId
    WHERE assignment_submission_date is NULL

    | studentName | assignmentId |
    +-------------+--------------+
    | John Doe    |           11 |
    | Alice Smith |           12 |
    | Bob Johnson |           13 |
    +-------------+--------------+
    3 rows in set (0.00 sec)

-- 9) Retrieve the list of all courses that have more than 50 students enrolled.
    SELECT courseName,count(*) as Total_Enrolled
    FROM course c
    INNER JOIN student_course sc ON sc.courseId=c.courseId
    GROUP BY courseName
    HAVING Total_Enrolled > 50;

-- 10) Retrieve the list of all students who have an overall grade average of 90% or higher.
    SELECT studentName, avg(stdcourse_numeric_grade) as avgGrade
    FROM student s
    INNER JOIN student_course sc ON sc.studentId=s.studentId
    INNER JOIN course c ON c.courseId=sc.courseId
    GROUP BY studentName
    HAVING avgGrade > 90;
    +------------------+----------+
    | studentName      | avgGrade |
    +------------------+----------+
    | Bob Johnson      |  92.0000 |
    | Michael Davis    |  92.6667 |
    | Olivia Taylor    |  94.0000 |
    | Sophia Rodriguez |  93.0000 |
    +------------------+----------+
    4 rows in set (0.01 sec)

-- 11) Retrieve the overall average grade for each course.
    SELECT c.courseName, avg(stdcourse_numeric_grade) as avgGrade
    FROM student_course sc
    INNER JOIN course c ON c.courseId=sc.courseId
    GROUP BY c.courseName;
    +--------------------+----------+
    | courseName         | avgGrade |
    +--------------------+----------+
    | English Literature |  90.0000 |
    | Calculus           |  85.0000 |
    | Biology            |  92.0000 |
    | World History      |  88.0000 |
    | Computer Science   |  95.0000 |
    | Art Appreciation   |  86.5000 |
    | Music Theory       |  90.0000 |
    | Physics            |  93.0000 |
    | Geography          |  87.0000 |
    | Language Arts      |  93.0000 |
    +--------------------+----------+
    10 rows in set (0.00 sec)

-- 12) Retrieve the average grade for each assignment in a specific course.
    SELECT a.assignmentId,c.courseId, avg(assignment_numeric_grade) as avgGrade
    FROM assignment a
    INNER JOIN student_assignment sa ON sa.assignmentId=a.assignmentId
    INNER JOIN student s ON s.studentId=sa.studentId
    INNER JOIN student_course sc ON sc.studentId=s.studentId
    INNER JOIN course c ON c.courseId=sc.courseId
    WHERE c.courseId=1
    GROUP BY a.assignmentId,c.courseId;
    +--------------+----------+----------+
    | assignmentId | courseId | avgGrade |
    +--------------+----------+----------+
    |            1 |        1 |  85.0000 |
    |           11 |        1 |   0.0000 |
    |           14 |        1 |  85.0000 |
    |           15 |        1 |  92.0000 |
    +--------------+----------+----------+
    4 rows in set (0.00 sec)

-- 13) Retrieve the number of students who have completed each assignment in a specific course.
     SELECT a.assignmentId,c.courseId, count(*) as std_count
     FROM assignment a
     INNER JOIN student_assignment sa ON sa.assignmentId=a.assignmentId
     INNER JOIN student s ON s.studentId=sa.studentId
     INNER JOIN student_course sc ON sc.studentId=s.studentId
     INNER JOIN course c ON c.courseId=sc.courseId
     WHERE assignment_submission_date is not NULL and c.courseId=2
     GROUP BY a.assignmentId,c.courseId;
    +--------------+----------+-----------+
    | assignmentId | courseId | std_count |
    +--------------+----------+-----------+
    |            2 |        2 |         1 |
    |           17 |        2 |         1 |
    |           19 |        2 |         1 |
    +--------------+----------+-----------+
    3 rows in set (0.00 sec)

-- 14) Retrieve the top 5 students with the highest overall grade average.
     SELECT studentName, avg(stdcourse_numeric_grade) as Grade
     FROM student s
     INNER JOIN student_course sc ON sc.studentId=s.studentId
     INNER JOIN course c ON c.courseId=sc.courseId
     WHERE stdcourse_numeric_grade is not null
     GROUP BY studentName
     ORDER BY Grade DESC LIMIT 5;
    +------------------+---------+
    | studentName      | Grade   |
    +------------------+---------+
    | Olivia Taylor    | 94.0000 |
    | Sophia Rodriguez | 93.0000 |
    | Michael Davis    | 92.6667 |
    | Bob Johnson      | 92.0000 |
    | Ryan Martinez    | 90.0000 |
    +------------------+---------+
    5 rows in set (0.00 sec)


-- 15) Retrieve the instructor with the highest overall average grade for all courses they teach.
    SELECT i.instructorId, max(avgGrade) as highestAvgGrade
    FROM
        instructor i
    INNER JOIN
    (
        SELECT t1.courseId, t2.instructorId, avg(t1.stdcourse_numeric_grade) as avgGrade
        FROM (
                 SELECT courseId, stdcourse_numeric_grade
                 FROM student_course sc
                 WHERE stdcourse_numeric_grade IS NOT NULL
                   AND courseId IN (
                      SELECT c.courseId
                      FROM instructor i
                      INNER JOIN course_instructor ci ON ci.instructorId = i.instructorId
                      INNER JOIN course c ON c.courseId = ci.courseId
                 )
             ) t1
        INNER JOIN (
            SELECT c.courseId, i.instructorId
            FROM instructor i
            INNER JOIN course_instructor ci ON ci.instructorId = i.instructorId
            INNER JOIN course c ON c.courseId = ci.courseId
        ) t2
        ON t1.courseId = t2.courseId
        GROUP BY t1.courseId, t2.instructorId
    ) t3
    ON t3.instructorId = i.instructorId
    GROUP BY t3.instructorId
    +--------------+-----------------+
    | instructorId | highestAvgGrade |
    +--------------+-----------------+
    |            1 |         90.0000 |
    |            2 |         90.0000 |
    |            3 |         68.5000 |
    |            4 |         88.0000 |
    |            5 |         95.0000 |
    |            6 |         95.0000 |
    |            7 |         90.0000 |
    |            8 |         90.0000 |
    |            9 |         87.0000 |
    |           10 |         93.0000 |
    +--------------+-----------------+
    10 rows in set (0.01 sec)

-- 16) Retrieve the list of students who have a grade of A in a specific course.
    SELECT studentName,stdcourse_letter_grade as Grade
    FROM student s
    INNER JOIN student_course sc ON sc.studentId=s.studentId
    INNER JOIN course c ON c.courseId=sc.courseId
    WHERE stdcourse_letter_grade='A' and sc.courseId=1;
    +-------------+-------+
    | studentName | Grade |
    +-------------+-------+
    | John Doe    | A     |
    +-------------+-------+
    1 row in set (0.00 sec)

-- 17) Retrieve the list of courses that have no assignments.
    SELECT c.courseId,courseName
    FROM course c
        WHERE c.courseId NOT IN (
            SELECT ca.courseId
            FROM course c
                     INNER JOIN course_assignment ca ON ca.courseId = c.courseId
                     INNER JOIN assignment a ON a.assignmentId = ca.assignmentId
                     INNER JOIN student_assignment sa ON sa.assignmentId = a.assignmentId
        );
        +----------+---------------+
        | courseId | courseName    |
        +----------+---------------+
        |        8 | Physics       |
        |        9 | Geography     |
        |       10 | Language Arts |
        +----------+---------------+
        3 rows in set (0.00 sec)

-- 18) Retrieve the list of students who have the highest grade in a specific course.
    SELECT studentName, max(stdcourse_numeric_grade) as HighestGrade
    FROM student s
    INNER JOIN  student_course sc ON sc.studentId=s.studentId
    INNER JOIN course c ON c.courseId=sc.courseId
    GROUP BY studentName
    +------------------+--------------+
    | studentName      | HighestGrade |
    +------------------+--------------+
    | John Doe         |           90 |
    | Alice Smith      |           92 |
    | Bob Johnson      |           92 |
    | Emma Brown       |           88 |
    | Michael Davis    |           95 |
    | Sarah Wilson     |           95 |
    | Ryan Martinez    |           90 |
    | Olivia Taylor    |           94 |
    | David White      |           87 |
    | Sophia Rodriguez |           93 |
    +------------------+--------------+
    10 rows in set (0.00 sec)

-- 19) Retrieve the list of assignments that have the lowest average grade in a specific course.

    SELECT sa.assignmentId, min(assignment_numeric_grade) as minGrade
    FROM assignment a
    INNER JOIN student_assignment sa ON sa.assignmentId=a.assignmentId
    GROUP BY sa.assignmentId
    HAVING minGrade = (
        SELECT avg(assignment_numeric_grade) as avgGrade
        FROM student s
        INNER JOIN student_assignment sa ON sa.studentId=sa.studentId
        INNER JOIN assignment a ON a.assignmentId=sa.assignmentId
        INNER JOIN student_course sc ON sc.studentId=s.studentId
        INNER JOIN course c ON c.courseId = sc.courseId
        WHERE c.courseId =2
    )


-- 20) Retrieve the list of students who have not enrolled in any course.
    SELECT s.studentName
    FROM student s
    WHERE studentId NOT IN (
        SELECT studentId
        FROM student_course
    );

    +------------------+
    | studentName      |
    +------------------+
    | Phurpa Wangchuk  |
    | Dann Astony      |
    | Marc Kuty        |
    +------------------+
    3 rows in set (0.00 sec)

SELECT *
FROM student s
         LEFT JOIN student_course sc ON s.studentId = sc.studentId

-- 21) Retrieve the list of instructors who are teaching more than one course.
    SELECT i.instructorName,i.instructorId,count(*) as courseCount
    FROM instructor i
    INNER JOIN course_instructor ic ON ic.instructorId=i.instructorId
    GROUP BY i.instructorName,i.instructorId
    HAVING courseCount > 1;
    +----------------+--------------+-------------+
    | instructorName | instructorId | courseCount |
    +----------------+--------------+-------------+
    | Prof. Smith    |            1 |           2 |
    | Dr. Johnson    |            2 |           2 |
    | Mr. Brown      |            4 |           2 |
    | Dr. Martinez   |            6 |           2 |
    | Mr. White      |            8 |           2 |
    +----------------+--------------+-------------+
    5 rows in set (0.01 sec)

-- 22) Retrieve the list of students who have not submitted an assignment for a specific course.
    SELECT s.studentId,a.assignmentId,c.courseName
    FROM student s
    INNER JOIN student_assignment sa ON sa.studentId=s.studentId
    INNER JOIN assignment a ON a.assignmentId=sa.assignmentId
    INNER JOIN student_course sc ON sc.studentId=s.studentId
    INNER JOIN course c ON c.courseId=sc.courseId
    WHERE assignment_submission_date is null;
    +-----------+--------------+--------------------+
    | studentId | assignmentId | courseName         |
    +-----------+--------------+--------------------+
    |         1 |           11 | English Literature |
    |         2 |           12 | Calculus           |
    |         3 |           13 | Biology            |
    +-----------+--------------+--------------------+
    3 rows in set (0.00 sec)

-- 23) Retrieve the list of courses that have the highest average grade.

    WITH course_with_highest_grade AS (
            SELECT courseId, max(stdcourse_numeric_grade) as higestAvgGrade
            FROM student_course
            GROUP BY courseId
        ),
        course_average_grade AS (
            SELECT courseId, avg(stdcourse_numeric_grade) as avgGrade
            FROM student_course
            GROUP BY courseId
        )
        SELECT c.courseName, ch.higestAvgGrade, ca.avgGrade
        FROM course c
        JOIN course_with_highest_grade ch ON ch.courseId=c.courseId
        JOIN course_average_grade ca ON ca.courseId=ch.courseId AND ca.avgGrade < ch.higestAvgGrade
        +------------------+----------------+----------+
        | courseName       | higestAvgGrade | avgGrade |
        +------------------+----------------+----------+
        | Biology          |             92 |  68.5000 |
        | Art Appreciation |             88 |  86.5000 |
        | Music Theory     |             95 |  90.0000 |
        | Physics          |             95 |  76.3333 |
        +------------------+----------------+----------+
        4 rows in set (0.00 sec)

-- 24) Retrieve the list of assignments that have a grade average higher than the overall grade average.
    SELECT assignmentId, avg(assignment_numeric_grade) as Grade
    FROM student_assignment
    GROUP BY assignmentId
    HAVING Grade > (
            SELECT avg(assignment_numeric_grade)
            FROM student_assignment
        )
    +--------------+---------+
    | assignmentId | Grade   |
    +--------------+---------+
    |            1 | 85.0000 |
    |            2 | 92.0000 |
    |            3 | 78.0000 |
    |            4 | 95.0000 |
    |            5 | 80.0000 |
    |            6 | 88.0000 |
    |            7 | 92.0000 |
    |            8 | 85.0000 |
    |            9 | 90.0000 |
    |           10 | 94.0000 |
    |           14 | 85.0000 |
    |           15 | 92.0000 |
    |           16 | 78.0000 |
    |           17 | 95.0000 |
    |           18 | 78.0000 |
    |           19 | 95.0000 |
    |           20 | 80.0000 |
    +--------------+---------+
    17 rows in set (0.00 sec)

-- 25) Retrieve the list of courses that have at least one student with a grade of F.
    SELECT courseName
    FROM course c
    INNER JOIN student_course sc ON sc.courseId=c.courseId
    WHERE stdcourse_letter_grade='F'
    +------------+
    | courseName |
    +------------+
    | Physics    |
    | Biology    |
    +------------+
    2 rows in set (0.01 sec)

-- 26) Retrieve the list of students who have the same grade in all their courses.
    WITH student_list AS (
            SELECT sc.courseId,s.studentId,s.studentName
            FROM student_course sc
            JOIN student s ON s.studentId=sc.studentId
            ),
        courses_with_grade (studentId,stdcourse_letter_grade,studentCount) AS (
            SELECT
                studentId,
                stdcourse_letter_grade,
                count(studentId) as studentCount
            FROM
                student_course
            group by
                studentId,stdcourse_letter_grade
        ),
        stdCount (studentId,studentIdCount) AS (
            SELECT
                studentId,
                count(studentId) as studentIdCount
            FROM
                courses_with_grade
            group by
                studentId
            having
                count(studentId) = 1
            )
        SELECT distinct s.studentName,cg.stdcourse_letter_grade as Grade
        FROM student_list s
        JOIN courses_with_grade cg ON cg.studentId=s.studentId
        JOIN stdCount sc ON sc.studentId=cg.studentId
        WHERE cg.stdcourse_letter_grade is not null
        +------------------+-------+
        | studentName      | Grade |
        +------------------+-------+
        | Bob Johnson      | A     |
        | Emma Brown       | B+    |
        | Michael Davis    | A     |
        | Ryan Martinez    | A     |
        | Olivia Taylor    | A     |
        | David White      | B+    |
        | Sophia Rodriguez | A     |
        +------------------+-------+
        7 rows in set (0.01 sec)


-- 27) Retrieve the list of courses that have the same number of enrolled students.
    WITH course_enrollment_counts(courseId,enrolled_students_count) AS (
            SELECT
                courseId,count(studentId) AS enrolled_students_count
            FROM
                student_course
            GROUP BY
                courseId
        )
        SELECT
            ce1.courseId,
            ce2.courseId,
            ce1.enrolled_students_count AS enrolled_students_count
        FROM
            course_enrollment_counts ce1
            JOIN course_enrollment_counts ce2 ON ce1.enrolled_students_count = ce2.enrolled_students_count
                AND ce1.courseId < ce2.courseId;
    +----------+----------+-------------------------+
    | courseId | courseId | enrolled_students_count |
    +----------+----------+-------------------------+
    |        1 |        2 |                       2 |
    |        2 |        4 |                       2 |
    |        1 |        4 |                       2 |
    |        4 |        6 |                       2 |
    |        2 |        6 |                       2 |
    |        1 |        6 |                       2 |
    |        3 |        7 |                       3 |
    |        7 |        8 |                       3 |
    |        3 |        8 |                       3 |
    |        5 |        9 |                       1 |
    |        9 |       10 |                       1 |
    |        5 |       10 |                       1 |
    +----------+----------+-------------------------+
    12 rows in set (0.01 sec)

-- 28) Retrieve the list of instructors who have taught all courses.
    WITH instuctor_list (instructorId,instructorName) AS(
        SELECT instructorId,instructorName
        FROM instructor i
        WHERE instructorId IN (
                SELECT i.instructorId
                FROM instructor i
                INNER JOIN course_instructor ci ON ci.instructorId=i.instructorId
                INNER JOIN course c ON c.courseId=ci.courseId
            )
    ),
    courses_taught_by_instructor(courseId,instructorId,courseName) AS (
        SELECT c.courseId,ci.instructorId,courseName
        FROM course c
        JOIN course_instructor ci ON ci.courseId = c.courseId
    )
    SELECT il.instructorId,il.instructorName,ct.courseName
    FROM instuctor_list il
    JOIN courses_taught_by_instructor ct ON ct.instructorId=il.instructorId
    +--------------+-----------------+--------------------+
    | instructorId | instructorName  | courseName         |
    +--------------+-----------------+--------------------+
    |            1 | Prof. Smith     | English Literature |
    |            1 | Prof. Smith     | Geography          |
    |            2 | Dr. Johnson     | Calculus           |
    |            2 | Dr. Johnson     | English Literature |
    |            3 | Ms. Williams    | Biology            |
    |            4 | Mr. Brown       | World History      |
    |            4 | Mr. Brown       | Biology            |
    |            5 | Prof. Davis     | Computer Science   |
    |            6 | Dr. Martinez    | Art Appreciation   |
    |            6 | Dr. Martinez    | Computer Science   |
    |            7 | Ms. Taylor      | Music Theory       |
    |            8 | Mr. White       | Physics            |
    |            8 | Mr. White       | Music Theory       |
    |            9 | Prof. Rodriguez | Geography          |
    |           10 | Dr. Wilson      | Language Arts      |
    +--------------+-----------------+--------------------+
    15 rows in set (0.01 sec)

-- 29) Retrieve the list of assignments that have been graded but not returned to the students.
    SELECT sa.assignmentId
    FROM assignment a
    INNER JOIN student_assignment sa ON sa.assignmentId=a.assignmentId
    WHERE assignment_graded_date is not null and assignment_returned_date is null;

-- 30) Retrieve the list of courses that have an average grade higher than the overall grade average.
    WITH course_overall_average_grade AS (
        SELECT studentId,courseId, avg(stdcourse_numeric_grade) as over_all_grade
        FROM student_course
        GROUP BY studentId,courseId
    ),
    average_grade AS (
        SELECT sc.courseId,avg(stdcourse_numeric_grade) as avgGrade
        FROM student_course sc
        JOIN course c ON c.courseId=sc.courseId
        WHERE stdcourse_numeric_grade is not null
        GROUP BY sc.courseId
    )
    SELECT c.courseName, over_all_grade, avgGrade
    FROM course c
    JOIN course_overall_average_grade co ON co.courseId=c.courseId
    JOIN average_grade ag ON ag.courseId=c.courseId
    WHERE ag.avgGrade > co.over_all_grade

    +------------------+----------------+----------+
    | courseName       | over_all_grade | avgGrade |
    +------------------+----------------+----------+
    | Music Theory     |        85.0000 |  90.0000 |
    | Physics          |        40.0000 |  76.3333 |
    | Biology          |        45.0000 |  68.5000 |
    | Art Appreciation |        85.0000 |  86.5000 |
    +------------------+----------------+----------+
    4 rows in set (0.01 sec)