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
SELECT instructorName
FROM instructor i
INNER JOIN course_instructor ci ON ci.instructorId = i.instructorId
INNER JOIN course c ON c.courseId=ci.courseId

SELECT c.courseId
    FROM instructor i
    INNER JOIN course_instructor ci ON ci.instructorId = i.instructorId
    INNER JOIN course c ON c.courseId=ci.courseId

    SELECT courseId,
    FROM student_course sc
    GROUP BY courseId


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
        WHERE c.courseId=1
    )
   ???

-- 20) Retrieve the list of students who have not enrolled in any course.
    SELECT s.studentName
    FROM student s
    LEFT JOIN student_course sc ON s.studentId = sc.studentId
    WHERE sc.studentId IS NULL;
    +------------------+
    | studentName      |
    +------------------+
    | Sophia Rodriguez |
    | Phurpa Wangchuk  |
    | Dann Astony      |
    | Marc Kuty        |
    +------------------+
    4 rows in set (0.00 sec)

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
    SELECT courseName, avg(stdcourse_numeric_grade) as maxAvgGrade
    FROM course c
    INNER JOIN student_course sc ON sc.courseId=c.courseId
    GROUP BY courseName
    ORDER BY maxAvgGrade DESC;
    +--------------------+-------------+
    | courseName         | maxAvgGrade |
    +--------------------+-------------+
    | Computer Science   |     95.0000 |
    | Physics            |     93.0000 |
    | Language Arts      |     93.0000 |
    | Biology            |     92.0000 |
    | English Literature |     90.0000 |
    | Music Theory       |     90.0000 |
    | World History      |     88.0000 |
    | Geography          |     87.0000 |
    | Art Appreciation   |     86.5000 |
    | Calculus           |     85.0000 |
    +--------------------+-------------+
    10 rows in set (0.00 sec)

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
    SELECT studentName, count(DISTINCT sc.stdcourse_letter_grade) as gradeCount
    FROM student s
    INNER JOIN student_course sc ON s.studentId = sc.studentId
    GROUP BY studentName
    HAVING COUNT(DISTINCT sc.stdcourse_letter_grade) = 1;
    +------------------+
    | studentName      |
    +------------------+
    | Bob Johnson      |
    | Emma Brown       |
    | Ryan Martinez    |
    | Olivia Taylor    |
    | David White      |
    | Sophia Rodriguez |
    +------------------+
    6 rows in set (0.01 sec)

-- 27) Retrieve the list of courses that have the same number of enrolled students.
    SELECT c.courseName,count(sc.courseId) as Total_Std_Enrolled
    FROM course c
    INNER JOIN student_course sc ON c.courseId = sc.courseId
    GROUP BY c.courseName
    HAVING Total_Std_Enrolled = (
            SELECT count(DISTINCT studentId) as stdCount
            FROM student_course
            GROUP BY courseId
            LIMIT 1
        );
    +--------------------+--------------------+
    | courseName         | Total_Std_Enrolled |
    +--------------------+--------------------+
    | English Literature |                  2 |
    | Calculus           |                  2 |
    | World History      |                  2 |
    | Art Appreciation   |                  2 |
    +--------------------+--------------------+
    4 rows in set (0.00 sec)

-- 28) Retrieve the list of instructors who have taught all courses.
    SELECT instructorName
    FROM instructor i
    WHERE instructorId IN (
            SELECT i.instructorId
            FROM instructor i
            INNER JOIN course_instructor ci ON ci.instructorId=i.instructorId
            INNER JOIN course c ON c.courseId=ci.courseId
        )
    +-----------------+
    | instructorName  |
    +-----------------+
    | Prof. Smith     |
    | Dr. Johnson     |
    | Ms. Williams    |
    | Mr. Brown       |
    | Prof. Davis     |
    | Dr. Martinez    |
    | Ms. Taylor      |
    | Mr. White       |
    | Prof. Rodriguez |
    | Dr. Wilson      |
    +-----------------+
    10 rows in set (0.02 sec)


-- 29) Retrieve the list of assignments that have been graded but not returned to the students.
    SELECT sa.assignmentId
    FROM assignment a
    INNER JOIN student_assignment sa ON sa.assignmentId=a.assignmentId
    WHERE assignment_graded_date is not null and assignment_returned_date is null;

-- 30) Retrieve the list of courses that have an average grade higher than the overall grade average.
