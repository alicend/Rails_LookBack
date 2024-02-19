import {
  CATEGORY_RESPONSE,
  CATEGORY,
  DELETE_CATEGORY_RESPONSE,
  UPDATE_CATEGORY_RESPONSE,
} from "@/types/CategoryType";
import {
  TASK_RESPONSE,
  POST_TASK,
  TASK_STATE,
  READ_TASK,
} from "@/types/TaskType";
import { USER_RESPONSE, USER } from "@/types/UserType";
import { RootState } from "../store/store";
import { createSlice, PayloadAction, createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";
import router from "next/router";
import { PAYLOAD } from "@/types/ResponseType";
import { COMMON_HTTP_HEADER } from "@/constants";

// 共通のエラーハンドラ
const handleHttpError = (err: any, thunkAPI: any) => {
  console.log(err);
  return thunkAPI.rejectWithValue({
    response: err.response.data,
    status: err.response.status,
  });
};

// APIエンドポイントの定義
const ENDPOINTS = {
  TASKS: `${process.env.NEXT_PUBLIC_RESTAPI_URL}tasks`,
  USERS: `${process.env.NEXT_PUBLIC_RESTAPI_URL}users`,
  CATEGORY: `${process.env.NEXT_PUBLIC_RESTAPI_URL}categories`,
};

export const fetchAsyncGetTaskBoardTasks = createAsyncThunk(
  "task/getTaskBoardTasks",
  async (_, thunkAPI) => {
    try {
      const res = await axios.get<TASK_RESPONSE>(
        `${ENDPOINTS.TASKS}/task-board`,
        COMMON_HTTP_HEADER,
      );
      return res.data.tasks;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncGetLookBackTasks = createAsyncThunk(
  "task/getLookBackTasks",
  async (_, thunkAPI) => {
    try {
      const res = await axios.get<TASK_RESPONSE>(
        `${ENDPOINTS.TASKS}/look-back`,
        COMMON_HTTP_HEADER,
      );
      return res.data.tasks;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncGetUsers = createAsyncThunk(
  "task/getUsers",
  async (_, thunkAPI) => {
    try {
      const res = await axios.get<USER_RESPONSE>(
        ENDPOINTS.USERS,
        COMMON_HTTP_HEADER,
      );
      return res.data.users;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncGetCategory = createAsyncThunk(
  "task/getCategory",
  async (_, thunkAPI) => {
    try {
      const res = await axios.get<CATEGORY_RESPONSE>(
        ENDPOINTS.CATEGORY,
        COMMON_HTTP_HEADER,
      );
      return res.data.categories;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncCreateCategory = createAsyncThunk(
  "task/createCategory",
  async (category: string, thunkAPI) => {
    try {
      const res = await axios.post<CATEGORY_RESPONSE>(
        ENDPOINTS.CATEGORY,
        { category: category },
        COMMON_HTTP_HEADER,
      );
      return res.data.categories;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncUpdateCategory = createAsyncThunk(
  "task/updateCategory",
  async (category: CATEGORY, thunkAPI) => {
    try {
      const res = await axios.put<UPDATE_CATEGORY_RESPONSE>(
        `${ENDPOINTS.CATEGORY}/${category.ID}`,
        { category: category.Category },
        COMMON_HTTP_HEADER,
      );
      return {
        categories: res.data.categories,
        tasks: res.data.tasks,
      };
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncDeleteCategory = createAsyncThunk(
  "task/deleteCategory",
  async (id: number, thunkAPI) => {
    try {
      const res = await axios.delete<DELETE_CATEGORY_RESPONSE>(
        `${ENDPOINTS.CATEGORY}/${id}`,
        COMMON_HTTP_HEADER,
      );
      return {
        categories: res.data.categories,
        tasks: res.data.tasks,
        CategoryID: id,
      };
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncCreateTask = createAsyncThunk(
  "task/createTask",
  async (task: POST_TASK, thunkAPI) => {
    try {
      const res = await axios.post<TASK_RESPONSE>(
        ENDPOINTS.TASKS,
        task,
        COMMON_HTTP_HEADER,
      );
      return res.data.tasks;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncUpdateTask = createAsyncThunk(
  "task/updateTask",
  async (task: POST_TASK, thunkAPI) => {
    try {
      const res = await axios.put<TASK_RESPONSE>(
        `${ENDPOINTS.TASKS}/${task.ID}`,
        task,
        COMMON_HTTP_HEADER,
      );
      return res.data.tasks;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncUpdateTaskToMoveToCompleted = createAsyncThunk(
  "task/updateToCompleted",
  async (task: POST_TASK, thunkAPI) => {
    try {
      const res = await axios.put<TASK_RESPONSE>(
        `${ENDPOINTS.TASKS}/${task.ID}/to-completed`,
        {
          ...task,
          Status: 3,
        },
        COMMON_HTTP_HEADER,
      );
      return res.data.tasks;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const fetchAsyncDeleteTask = createAsyncThunk(
  "task/deleteTask",
  async (id: number, thunkAPI) => {
    try {
      const res = await axios.delete<TASK_RESPONSE>(
        `${ENDPOINTS.TASKS}/${id}`,
        COMMON_HTTP_HEADER,
      );
      return res.data.tasks;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  },
);

export const initialState: TASK_STATE = {
  message: "",
  status: "",
  tasks: [
    {
      ID: 0,
      Task: "",
      Description: "",
      StartDate: "",
      Creator: 0,
      CreatorUserName: "",
      Responsible: 0,
      ResponsibleUserName: "",
      Estimate: 1,
      Category: 0,
      CategoryName: "",
      Status: 0,
      StatusName: "",
      CreatedAt: "",
      UpdatedAt: "",
    },
  ],
  editedTask: {
    ID: 0,
    Task: "",
    Description: "",
    StartDate: "",
    Responsible: 0,
    Estimate: 1,
    Category: 0,
    Status: 0,
  },
  selectedTask: {
    ID: 0,
    Task: "",
    Description: "",
    StartDate: "",
    Creator: 0,
    CreatorUserName: "",
    Responsible: 0,
    ResponsibleUserName: "",
    Estimate: 1,
    Category: 0,
    CategoryName: "",
    Status: 0,
    StatusName: "",
    CreatedAt: "",
    UpdatedAt: "",
  },
  users: [
    {
      ID: 0,
      Email: "",
      Name: "",
      UserGroupID: 0,
      UserGroup: "",
    },
  ],
  category: [
    {
      ID: 0,
      Category: "",
    },
  ],
};

const handleError = (state: any, action: any) => {
  const payload = action.payload as PAYLOAD;
  if (payload.status === 401) {
    router.push("/");
  } else {
    const errorMessage = payload.response.message
      ? payload.response.message
      : payload.response.error;
    state.status = "failed";
    state.message = errorMessage;
  }
};

const handleLoading = (state: any) => {
  state.status = "loading";
};

const handleLoadingForInit = (state: any) => {};

export const taskSlice = createSlice({
  name: "task",
  initialState,
  reducers: {
    editTasks(state, action: PayloadAction<READ_TASK[]>) {
      state.tasks = action.payload;
    },
    editTask(state, action: PayloadAction<POST_TASK>) {
      state.editedTask = action.payload;
    },
    editSelectedTask(state, action: PayloadAction<READ_TASK>) {
      state.selectedTask = action.payload;
    },
    editTaskStatus(
      state,
      action: PayloadAction<"" | "loading" | "succeeded" | "failed">,
    ) {
      state.status = action.payload;
    },
    editTaskMessage(state, action: PayloadAction<string>) {
      state.message = action.payload;
    },
  },
  extraReducers: (builder) => {
    builder.addCase(
      fetchAsyncGetTaskBoardTasks.fulfilled,
      (state, action: PayloadAction<READ_TASK[]>) => {
        return {
          ...state,
          tasks: action.payload,
        };
      },
    );
    builder.addCase(fetchAsyncGetTaskBoardTasks.rejected, handleError);
    builder.addCase(fetchAsyncGetTaskBoardTasks.pending, handleLoadingForInit);
    builder.addCase(
      fetchAsyncGetLookBackTasks.fulfilled,
      (state, action: PayloadAction<READ_TASK[]>) => {
        return {
          ...state,
          tasks: action.payload,
        };
      },
    );
    builder.addCase(fetchAsyncGetLookBackTasks.rejected, handleError);
    builder.addCase(fetchAsyncGetLookBackTasks.pending, handleLoadingForInit);
    builder.addCase(
      fetchAsyncGetUsers.fulfilled,
      (state, action: PayloadAction<USER[]>) => {
        return {
          ...state,
          users: action.payload,
        };
      },
    );
    builder.addCase(fetchAsyncGetUsers.rejected, handleError);
    builder.addCase(fetchAsyncGetUsers.pending, handleLoadingForInit);
    builder.addCase(
      fetchAsyncGetCategory.fulfilled,
      (state, action: PayloadAction<CATEGORY[]>) => {
        return {
          ...state,
          category: action.payload,
        };
      },
    );
    builder.addCase(fetchAsyncGetCategory.rejected, handleError);
    builder.addCase(fetchAsyncGetCategory.pending, handleLoadingForInit);
    builder.addCase(
      fetchAsyncCreateCategory.fulfilled,
      (state, action: PayloadAction<CATEGORY[]>) => {
        return {
          ...state,
          category: action.payload,
          status: "succeeded",
          message: "カテゴリを作成しました",
        };
      },
    );
    builder.addCase(fetchAsyncCreateCategory.rejected, handleError);
    builder.addCase(fetchAsyncCreateCategory.pending, handleLoading);
    builder.addCase(
      fetchAsyncUpdateCategory.fulfilled,
      (state, action: PayloadAction<UPDATE_CATEGORY_RESPONSE>) => {
        return {
          ...state,
          category: action.payload.categories,
          tasks: action.payload.tasks,
          status: "succeeded",
          message: "カテゴリを更新しました",
        };
      },
    );
    builder.addCase(fetchAsyncUpdateCategory.rejected, handleError);
    builder.addCase(fetchAsyncUpdateCategory.pending, handleLoading);
    builder.addCase(
      fetchAsyncDeleteCategory.fulfilled,
      (state, action: PayloadAction<DELETE_CATEGORY_RESPONSE>) => {
        const isTaskPresent = action.payload.tasks.find(
          (task) => task.ID === state.editedTask.ID,
        );
        return {
          ...state,
          editedTask: isTaskPresent
            ? {
                ...state.editedTask,
                Category:
                  state.editedTask.Category === action.payload.CategoryID
                    ? 0
                    : state.editedTask.Category,
              }
            : initialState.editedTask,
          selectedTask: isTaskPresent
            ? state.selectedTask
            : initialState.selectedTask,
          category: action.payload.categories,
          tasks: action.payload.tasks,
          status: "succeeded",
          message: "カテゴリを削除しました",
        };
      },
    );
    builder.addCase(fetchAsyncDeleteCategory.rejected, handleError);
    builder.addCase(fetchAsyncDeleteCategory.pending, handleLoading);
    builder.addCase(
      fetchAsyncCreateTask.fulfilled,
      (state, action: PayloadAction<READ_TASK[]>) => {
        return {
          ...state,
          tasks: action.payload,
          editedTask: initialState.editedTask,
          status: "succeeded",
          message: "タスクを作成しました",
        };
      },
    );
    builder.addCase(fetchAsyncCreateTask.rejected, handleError);
    builder.addCase(fetchAsyncCreateTask.pending, handleLoading);
    builder.addCase(
      fetchAsyncUpdateTask.fulfilled,
      (state, action: PayloadAction<READ_TASK[]>) => {
        return {
          ...state,
          tasks: action.payload,
          editedTask: initialState.editedTask,
          selectedTask: initialState.selectedTask,
          status: "succeeded",
          message: "タスクを更新しました",
        };
      },
    );
    builder.addCase(fetchAsyncUpdateTask.rejected, handleError);
    builder.addCase(fetchAsyncUpdateTask.pending, handleLoading);
    builder.addCase(
      fetchAsyncUpdateTaskToMoveToCompleted.fulfilled,
      (state, action: PayloadAction<READ_TASK[]>) => {
        return {
          ...state,
          tasks: action.payload,
          editedTask: initialState.editedTask,
          selectedTask: initialState.selectedTask,
          status: "succeeded",
          message: "ステータスを完了に変更しました",
        };
      },
    );
    builder.addCase(
      fetchAsyncUpdateTaskToMoveToCompleted.rejected,
      handleError,
    );
    builder.addCase(
      fetchAsyncUpdateTaskToMoveToCompleted.pending,
      handleLoading,
    );
    builder.addCase(
      fetchAsyncDeleteTask.fulfilled,
      (state, action: PayloadAction<READ_TASK[]>) => {
        return {
          ...state,
          tasks: action.payload,
          editedTask: initialState.editedTask,
          selectedTask: initialState.selectedTask,
          status: "succeeded",
          message: "タスクを削除しました",
        };
      },
    );
    builder.addCase(fetchAsyncDeleteTask.rejected, handleError);
    builder.addCase(fetchAsyncDeleteTask.pending, handleLoading);
  },
});

export const {
  editTasks,
  editTask,
  editSelectedTask,
  editTaskStatus,
  editTaskMessage,
} = taskSlice.actions;
export const selectSelectedTask = (state: RootState) => state.task.selectedTask;
export const selectEditedTask = (state: RootState) => state.task.editedTask;
export const selectTasks = (state: RootState) => state.task.tasks;
export const selectUsers = (state: RootState) => state.task.users;
export const selectCategory = (state: RootState) => state.task.category;
export const selectTaskStatus = (state: RootState) => state.task.status;
export const selectTaskMessage = (state: RootState) => state.task.message;
export default taskSlice.reducer;
