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
-- 6) Retrieve the list of all assignments for a specific course.
-- 7) Retrieve the highest grade received by a specific student in a specific course.
-- 8) Retrieve the list of all students who have not completed a specific assignment.
-- 9) Retrieve the list of all courses that have more than 50 students enrolled.
-- 10) Retrieve the list of all students who have an overall grade average of 90% or higher.
-- 11) Retrieve the overall average grade for each course.
-- 12) Retrieve the average grade for each assignment in a specific course.
-- 13) Retrieve the number of students who have completed each assignment in a specific course.
-- 14) Retrieve the top 5 students with the highest overall grade average.
-- 15) Retrieve the instructor with the highest overall average grade for all courses they teach.
-- 16) Retrieve the list of students who have a grade of A in a specific course.
-- 17) Retrieve the list of courses that have no assignments.
-- 18) Retrieve the list of students who have the highest grade in a specific course.
-- 19) Retrieve the list of assignments that have the lowest average grade in a specific course.
-- 20) Retrieve the list of students who have not enrolled in any course.
-- 21) Retrieve the list of instructors who are teaching more than one course.
-- 22) Retrieve the list of students who have not submitted an assignment for a specific course.
-- 23) Retrieve the list of courses that have the highest average grade.
-- 24) Retrieve the list of assignments that have a grade average higher than the overall grade average.
-- 25) Retrieve the list of courses that have at least one student with a grade of F.
-- 26) Retrieve the list of students who have the same grade in all their courses.
-- 27) Retrieve the list of courses that have the same number of enrolled students.
-- 28) Retrieve the list of instructors who have taught all courses.
-- 29) Retrieve the list of assignments that have been graded but not returned to the students.
-- 30) Retrieve the list of courses that have an average grade higher than the overall grade average.