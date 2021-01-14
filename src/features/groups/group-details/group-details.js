import React from 'react';
import { shape } from 'prop-types';
import { Badge, Table } from 'react-bootstrap';
import { Link, useHistory } from 'react-router-dom';

import { paths } from '@/shared';
import { WithLoading, Button } from '@/components/index.js';
import {
  studentGroupByIdStateShape, studentsStateShape, mentorsStateShape, coursesStateShape,
} from '@/features/shared/index.js';
import styles from './group-details.scss';

export const GroupDetails = ({
  studentGroupData, studentsData, mentorsData, coursesData,
}) => {
  const {
    data: group,
    isLoading: isGroupLoading,
    isLoaded: isGroupLoaded,
  } = studentGroupData;
  const { data: students, isLoading: areStudentsLoading } = studentsData;
  const { data: mentors, isLoading: areMentorsLoading } = mentorsData;
  const { data: courses, isLoading: areCoursesLoading } = coursesData;

  const history = useHistory();

  const handleShowSchedule = () => {
    history.push(`${paths.SCHEDULE_BY_GROUP_ID}/${group.id}`);
  };

  return (
    <div className="container">
      <div className="row justify-content-center">
        <div className="w-100 card shadow p-4">
          <WithLoading isLoading={isGroupLoading || !isGroupLoaded} className={styles['loader-centered']}>
            <div className="d-flex flex-row text-left justify-content-between">
              <div className="d-flex flex-column">
                <h2>
                  Group: {group.name}
                </h2>
                <p className="m-0">
                  {new Date(group.startDate).toLocaleDateString()}
                  &nbsp;-&nbsp;
                  {new Date(group.finishDate).toLocaleDateString()}
                </p>
              </div>
              {/* <Button variant="primary" onClick={handleShowSchedule}>View schedule</Button> */}
              <Link to={`${paths.SCHEDULE_BY_GROUP_ID}/${group.id}`}>View schedule</Link>
            </div>
            <hr className="p-0" />
            <div className="d-flex mb-2">
              <h4 className="pr-2 mb-2">
                Mentors:
              </h4>
              <WithLoading isLoading={areMentorsLoading}>
                <div className="d-flex flex-wrap">
                  { mentors
                    .filter((mentor) => group.mentorIds?.includes(mentor.id))
                    .map((mentor) => (
                      <div className="pr-2 lead" key={mentor.id}>
                        <Badge pill variant="warning">
                          <Link
                            to={`${paths.MENTORS_DETAILS}/${mentor.id}`}
                            className="text-decoration-none text-dark"
                          >{mentor.firstName} {mentor.lastName}
                          </Link>
                        </Badge>
                      </div>
                    )) }
                </div>
              </WithLoading>
            </div>
            <div className="d-flex align-items-center mb-2 lead">
              <h4 className="mb-2 pr-4">Course:</h4>
              <WithLoading isLoading={areCoursesLoading}>
                <Badge pill variant="primary">
                  <Link
                    to={`${paths.COURSE_DETAILS}/${group.courseId}`}
                    className="text-decoration-none text-white"
                  >
                    {courses.find((course) => course.id === group.courseId)?.name }
                  </Link>
                </Badge>
              </WithLoading>
            </div>
            <h4 className="h4 my-2">
              Students:
            </h4>
            <WithLoading isLoading={areStudentsLoading}>
              <Table bordered hover responsive>
                <thead>
                  <tr>
                    <th>№</th>
                    <th>Name</th>
                    <th>Email</th>
                  </tr>
                </thead>
                <tbody>
                  { students
                    .filter((student) => group.studentIds?.includes(student.id))
                    .map((student, index) => (
                      <tr key={student.id}>
                        <td>{index + 1}</td>
                        <td>
                          <Link to={`${paths.STUDENTS_DETAILS}/${student.id}`}>
                            {student.firstName} {student.lastName}
                          </Link>
                        </td>
                        <td>{student.email}</td>
                      </tr>
                    )) }
                </tbody>
              </Table>
            </WithLoading>
          </WithLoading>
        </div>
      </div>
    </div>
  );
};

GroupDetails.propTypes = {
  studentGroupData: shape(studentGroupByIdStateShape).isRequired,
  studentsData: shape(studentsStateShape).isRequired,
  mentorsData: shape(mentorsStateShape).isRequired,
  coursesData: shape(coursesStateShape).isRequired,
};
