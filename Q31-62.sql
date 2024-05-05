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
-- 33) Retrieve the list of students who have submitted the most assignments.
-- 34) Retrieve the list of courses that have the highest average grade among students who have
-- submitted all assignments.
-- 35) Retrieve the list of courses that have the highest average grade among students who have
-- submitted all assignments.
-- 36) Retrieve the list of courses with the highest number of enrollments.
-- 37) Retrieve the list of assignments that have the lowest submission rate.
-- 38) Retrieve the list of students who have the highest average grade for a specific course.
-- 39) Retrieve the list of courses with the highest percentage of students who have completed all
-- assignments.
-- 40) Retrieve the list of students who have not submitted any assignments for a specific course.
-- 41) Retrieve the list of courses with the lowest average grade.
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