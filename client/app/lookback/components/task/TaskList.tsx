import AddCircleOutlineIcon from "@mui/icons-material/AddCircleOutline";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import {
  Button,
  Badge,
  Table,
  TableHead,
  TableCell,
  TableRow,
  TableBody,
  TableSortLabel,
  Hidden,
} from "@mui/material";
import { styled } from "@mui/system";
import dayjs from "dayjs";
import React, { useState, useEffect } from "react";

import { useSelector, useDispatch } from "react-redux";
import {
  selectTasks,
  editTask,
  editSelectedTask,
  initialState,
} from "@/slices/taskSlice";
import { AppDispatch } from "@/store/store";
import { SORT_STATE, READ_TASK } from "@/types/TaskType";

const StyledTableCell = styled(TableCell)({
  overflow: "hidden",
  textOverflow: "clip",
  whiteSpace: "normal",
});

const StyledButton = styled(Button)(({ theme }) => ({
  margin: theme.spacing(3),
  backgroundColor: "#4dabf5 !important",
  "&:hover": {
    backgroundColor: "#1769aa !important",
  },
  "&:disabled": {
    backgroundColor: "#ccc !important",
    cursor: "not-allowed",
  },
}));

const StyledTable = styled(Table)`
  table-layout: fixed;
`;

const TaskList: React.FC = () => {
  const dispatch: AppDispatch = useDispatch();
  const tasks = useSelector(selectTasks);
  const columns = tasks[0] && Object.keys(tasks[0]);

  const [state, setState] = useState<SORT_STATE>({
    rows: tasks,
    order: "desc",
    activeKey: "",
  });

  const handleClickSortColumn = (column: keyof READ_TASK) => {
    const isDesc = column === state.activeKey && state.order === "desc";
    const newOrder = isDesc ? "asc" : "desc";
    const sortedRows = Array.from(state.rows).sort((a, b) => {
      if (a[column] > b[column]) {
        return newOrder === "asc" ? 1 : -1;
      } else if (a[column] < b[column]) {
        return newOrder === "asc" ? -1 : 1;
      } else {
        return 0;
      }
    });

    setState({
      rows: sortedRows,
      order: newOrder,
      activeKey: column,
    });
  };

  useEffect(() => {
    setState((state) => ({
      ...state,
      rows: tasks,
    }));
  }, [tasks]);

  const renderSwitch = (statusName: string) => {
    switch (statusName) {
      case "未着":
        return (
          <Badge variant="dot" color="error">
            {statusName}
          </Badge>
        );
      case "進行中":
        return (
          <Badge variant="dot" color="primary">
            {statusName}
          </Badge>
        );
      case "完了":
        return (
          <Badge variant="dot" color="secondary">
            {statusName}
          </Badge>
        );
      default:
        return null;
    }
  };

  return (
    <>
      <StyledButton
        variant="contained"
        size="small"
        startIcon={<AddCircleOutlineIcon />}
        onClick={() => {
          dispatch(
            editTask({
              ID: 0,
              Task: "",
              Description: "",
              StartDate: dayjs().toISOString(),
              Responsible: 0,
              Status: 1,
              Category: 0,
              Estimate: 1,
            }),
          );
          dispatch(editSelectedTask(initialState.selectedTask));
        }}
      >
        Add new
      </StyledButton>
      {tasks[0]?.Task && (
        <>
          {/* Table for PC */}
          <Hidden smDown>
            <StyledTable size="small">
              <TableHead>
                <TableRow>
                  {columns.map((column, colIndex) => {
                    const columnLabel =
                      column === "Estimate" ? "Estimate [days]" : column;

                    return (
                      (column === "Task" ||
                        column === "Status" ||
                        column === "Category" ||
                        column === "StartDate" ||
                        column === "Estimate" ||
                        column === "Responsible" ||
                        column === "Creator") && (
                        <StyledTableCell className="break-words" key={colIndex}>
                          <TableSortLabel
                            active={state.activeKey === column}
                            direction={state.order}
                            onClick={() => handleClickSortColumn(column)}
                          >
                            <strong>{columnLabel}</strong>
                          </TableSortLabel>
                        </StyledTableCell>
                      )
                    );
                  })}
                  <TableCell></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {state.rows.map((row, rowIndex) => (
                  <TableRow hover key={rowIndex}>
                    {Object.keys(row).map(
                      (key, colIndex) =>
                        (key === "Task" ||
                          key === "StatusName" ||
                          key === "CategoryName" ||
                          key === "Estimate" ||
                          key === "StartDate" ||
                          key === "ResponsibleUserName" ||
                          key === "CreatorUserName") && (
                          <TableCell
                            className="break-words"
                            key={`${rowIndex}+${colIndex}`}
                            onClick={() => {
                              dispatch(editSelectedTask(row));
                              dispatch(editTask(initialState.editedTask));
                            }}
                          >
                            {key === "StatusName" ? (
                              renderSwitch(row[key])
                            ) : key === "Estimate" ? (
                              <span>
                                {row[key]} {row[key] === 1 ? "day" : "days"}
                              </span>
                            ) : (
                              <span>{row[key]}</span>
                            )}
                          </TableCell>
                        ),
                    )}
                    <TableCell>
                      <div className="text-gray-400 cursor-not-allowed">
                        <button
                          className="cursor-pointer bg-transparent border-none outline-none text-lg text-gray-500"
                          onClick={() => dispatch(editTask(row))}
                        >
                          <EditOutlinedIcon />
                        </button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </StyledTable>
          </Hidden>
          {/* Table for Mobile */}
          <Hidden smUp>
            <StyledTable size="small">
              <TableHead>
                <TableRow>
                  {columns.map((column, colIndex) => {
                    const columnLabel =
                      column === "Estimate" ? "Estimate [days]" : column;

                    return (
                      (column === "Task" || column === "Status") && (
                        <StyledTableCell className="break-words" key={colIndex}>
                          <TableSortLabel
                            active={state.activeKey === column}
                            direction={state.order}
                            onClick={() => handleClickSortColumn(column)}
                          >
                            <strong>{columnLabel}</strong>
                          </TableSortLabel>
                        </StyledTableCell>
                      )
                    );
                  })}
                  <TableCell></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {state.rows.map((row, rowIndex) => (
                  <TableRow hover key={rowIndex}>
                    {Object.keys(row).map(
                      (key, colIndex) =>
                        (key === "Task" || key === "StatusName") && (
                          <TableCell
                            className="break-words"
                            key={`${rowIndex}+${colIndex}`}
                            onClick={() => {
                              dispatch(editSelectedTask(row));
                              dispatch(editTask(initialState.editedTask));
                            }}
                          >
                            {key === "StatusName" ? (
                              renderSwitch(row[key])
                            ) : (
                              <span>{row[key]}</span>
                            )}
                          </TableCell>
                        ),
                    )}
                    <TableCell>
                      <div className="text-gray-400 cursor-not-allowed">
                        <button
                          className="cursor-pointer bg-transparent border-none outline-none text-lg text-gray-500"
                          onClick={() => dispatch(editTask(row))}
                        >
                          <EditOutlinedIcon />
                        </button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </StyledTable>
          </Hidden>
        </>
      )}
    </>
  );
};

export default TaskList;
