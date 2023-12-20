import { PayloadAction, createAsyncThunk, createSlice } from "@reduxjs/toolkit";
import axios from "axios";
import { LOGIN_AUTH, SIGN_UP_AUTH } from "@/types/AuthType";
import { RootState } from "@/store/store";
import {
  USER,
  USER_STATE,
  PASSWORD_UPDATE,
  PASSWORD_RESET,
} from "@/types/UserType";
import { PAYLOAD } from "@/types/ResponseType";
import router from "next/router";
import { COMMON_HTTP_HEADER } from "@/constants";

// 共通のエラーハンドラ
const handleHttpError = (err: any, thunkAPI: any) => {
  return thunkAPI.rejectWithValue({
    response: err.response.data,
    status: err.response.status,
  });
};

// APIエンドポイントの定義
const ENDPOINTS = {
  LOGIN: `${process.env.NEXT_PUBLIC_RESTAPI_URL}login`,
  LOGOUT: `${process.env.NEXT_PUBLIC_RESTAPI_URL}logout`,
  REGISTER: `${process.env.NEXT_PUBLIC_RESTAPI_URL}signup`,
  REGISTER_REQUEST: `${process.env.NEXT_PUBLIC_RESTAPI_URL}signup/request`,
  INVITE_REGISTER: `${process.env.NEXT_PUBLIC_RESTAPI_URL}invite/signup`,
  INVITE_REQUEST: `${process.env.NEXT_PUBLIC_RESTAPI_URL}invite/request`,
  USERS: `${process.env.NEXT_PUBLIC_RESTAPI_URL}users`,
};

export const fetchAsyncGuestLogin = createAsyncThunk(
  "auth/login/guest",
  async (_, thunkAPI) => {
    try {
      const res = await axios.get(
        `${ENDPOINTS.LOGIN}/guest`,
        COMMON_HTTP_HEADER
      );
      await router.push("/task-board");
      return res.data;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncLogin = createAsyncThunk(
  "auth/login",
  async (auth: LOGIN_AUTH, thunkAPI) => {
    try {
      const res = await axios.post(ENDPOINTS.LOGIN, auth, COMMON_HTTP_HEADER);
      await router.push("/task-board");
      return res.data;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncLogout = createAsyncThunk(
  "auth/logout",
  async (_, thunkAPI) => {
    try {
      const res = await axios.get(ENDPOINTS.LOGOUT, COMMON_HTTP_HEADER);
      await router.push("/");
      return res.data;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncRegisterRequest = createAsyncThunk(
  "auth/register/request",
  async (email: string, thunkAPI) => {
    try {
      const res = await axios.post(
        ENDPOINTS.REGISTER_REQUEST,
        { email: email },
        COMMON_HTTP_HEADER
      );
      return res.data;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncInviteRequest = createAsyncThunk(
  "auth/invite/request",
  async (
    { email, userGroupID }: { email: string; userGroupID: number },
    thunkAPI
  ) => {
    try {
      const res = await axios.post(
        ENDPOINTS.INVITE_REQUEST,
        { email: email, userGroupID: userGroupID },
        COMMON_HTTP_HEADER
      );
      return res.data;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncRegister = createAsyncThunk(
  "auth/register",
  async (auth: SIGN_UP_AUTH, thunkAPI) => {
    try {
      const res = await axios.post(
        ENDPOINTS.REGISTER,
        auth,
        COMMON_HTTP_HEADER
      );
      await router.push("/");
      return res.data;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncInviteRegister = createAsyncThunk(
  "auth/invite/register",
  async (auth: SIGN_UP_AUTH, thunkAPI) => {
    try {
      const res = await axios.post(
        ENDPOINTS.INVITE_REGISTER,
        auth,
        COMMON_HTTP_HEADER
      );
      await router.push("/");
      return res.data;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncGetLoginUser = createAsyncThunk(
  "users/getUser",
  async (_, thunkAPI) => {
    try {
      const res = await axios.get(`${ENDPOINTS.USERS}/me`, COMMON_HTTP_HEADER);
      return res.data.user;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncUpdateLoginUserEmail = createAsyncThunk(
  "users/updateUserEmail",
  async (email: string, thunkAPI) => {
    try {
      const res = await axios.put(
        `${ENDPOINTS.USERS}/me/email/request`,
        { email: email },
        COMMON_HTTP_HEADER
      );
      return res.data.user;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncUpdateCompleteLoginUserEmail = createAsyncThunk(
  "users/updateUserEmail/complete",
  async (email: string, thunkAPI) => {
    try {
      const res = await axios.put(
        `${ENDPOINTS.USERS}/me/email`,
        { email: email },
        COMMON_HTTP_HEADER
      );
      await router.push("/");
      return res.data.user;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncUpdateLoginUsername = createAsyncThunk(
  "users/updateUsername",
  async (username: string, thunkAPI) => {
    try {
      const res = await axios.put(
        `${ENDPOINTS.USERS}/me/name`,
        { username: username },
        COMMON_HTTP_HEADER
      );
      return res.data.user;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncUpdateLoginUserPassword = createAsyncThunk(
  "users/updateUserPassword",
  async (passwords: PASSWORD_UPDATE, thunkAPI) => {
    try {
      const res = await axios.put(
        `${ENDPOINTS.USERS}/me/password`,
        passwords,
        COMMON_HTTP_HEADER
      );
      return res.data.user;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncResetPasswordRequest = createAsyncThunk(
  "users/updateUserPassword/request",
  async (email: string, thunkAPI) => {
    try {
      const res = await axios.post(
        `${ENDPOINTS.USERS}/password/request`,
        { email: email },
        COMMON_HTTP_HEADER
      );
      return res.data.user;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncResetPassword = createAsyncThunk(
  "users/resetPassword",
  async (reset: PASSWORD_RESET, thunkAPI) => {
    try {
      const res = await axios.put(
        `${ENDPOINTS.USERS}/password`,
        reset,
        COMMON_HTTP_HEADER
      );
      await router.push("/");
      return res.data.user;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncUpdateUserGroup = createAsyncThunk(
  "user-groups/update",
  async ({ id, userGroup }: { id: number; userGroup: string }, thunkAPI) => {
    try {
      const res = await axios.put(
        `${ENDPOINTS.USERS}/me/user-group`,
        { userGroup: userGroup },
        COMMON_HTTP_HEADER
      );
      return res.data.user_groups;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

export const fetchAsyncDeleteLoginUser = createAsyncThunk(
  "users/deleteUser",
  async (_, thunkAPI) => {
    try {
      const res = await axios.delete(
        `${ENDPOINTS.USERS}/me`,
        COMMON_HTTP_HEADER
      );
      await router.push("/");
      return res.data.user;
    } catch (err: any) {
      return handleHttpError(err, thunkAPI);
    }
  }
);

const initialState: USER_STATE = {
  status: "",
  message: "",
  loginUser: {
    ID: 0,
    Email: "",
    Name: "",
    UserGroupID: 0,
    UserGroup: "",
  },
};

const handleError = (state: any, action: any) => {
  const payload = action.payload as PAYLOAD;
  if (payload.status === 401) {
    router.push("/");
  } else {
    if (action.payload && action.payload.response) {
      const errorMessage = action.payload.response.message
        ? action.payload.response.message
        : action.payload.response.error;
      state.status = "failed";
      state.message = errorMessage;
    } else {
      state.status = "failed";
      state.message = "Unknown error";
    }
  }
};

const handleLoginError = (state: any, action: any) => {
  const payload = action.payload as PAYLOAD;
  if (action.payload && action.payload.response) {
    const errorMessage = action.payload.response.message
      ? action.payload.response.message
      : action.payload.response.error;
    state.status = "failed";
    state.message = errorMessage;
  } else {
    state.status = "failed";
    state.message = "Unknown error";
  }
};

const handleLoading = (state: any) => {
  state.status = "loading";
};

export const userSlice = createSlice({
  name: "user",
  initialState,
  reducers: {
    setLoginUser: (state, action) => {
      state.loginUser = action.payload;
    },
    editUserStatus(
      state,
      action: PayloadAction<"" | "loading" | "succeeded" | "failed">
    ) {
      state.status = action.payload;
    },
    editUserMessage(state, action: PayloadAction<string>) {
      state.message = action.payload;
    },
  },
  extraReducers: (builder) => {
    builder.addCase(
      fetchAsyncGuestLogin.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.loginUser = action.payload;
        state.message = "ログインに成功しました";
      }
    );
    builder.addCase(fetchAsyncGuestLogin.rejected, handleLoginError);
    builder.addCase(fetchAsyncGuestLogin.pending, handleLoading);
    builder.addCase(
      fetchAsyncLogin.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.loginUser = action.payload;
        state.message = "ログインに成功しました";
      }
    );
    builder.addCase(fetchAsyncLogin.rejected, handleLoginError);
    builder.addCase(fetchAsyncLogin.pending, handleLoading);
    builder.addCase(
      fetchAsyncLogout.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "ログアウトしました";
      }
    );
    builder.addCase(fetchAsyncLogout.rejected, handleLoginError);
    builder.addCase(fetchAsyncLogout.pending, handleLoading);
    builder.addCase(
      fetchAsyncRegisterRequest.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "メールを送信しました";
      }
    );
    builder.addCase(fetchAsyncRegisterRequest.rejected, handleLoginError);
    builder.addCase(fetchAsyncRegisterRequest.pending, handleLoading);
    builder.addCase(
      fetchAsyncInviteRequest.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "メールを送信しました";
      }
    );
    builder.addCase(fetchAsyncInviteRequest.rejected, handleLoginError);
    builder.addCase(fetchAsyncInviteRequest.pending, handleLoading);
    builder.addCase(
      fetchAsyncRegister.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "ユーザーの登録に成功しました";
      }
    );
    builder.addCase(fetchAsyncRegister.rejected, handleLoginError);
    builder.addCase(fetchAsyncRegister.pending, handleLoading);

    builder.addCase(
      fetchAsyncInviteRegister.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "ユーザーの登録に成功しました";
      }
    );
    builder.addCase(fetchAsyncInviteRegister.rejected, handleLoginError);
    builder.addCase(fetchAsyncInviteRegister.pending, handleLoading);
    builder.addCase(
      fetchAsyncGetLoginUser.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.loginUser = action.payload;
      }
    );
    builder.addCase(fetchAsyncGetLoginUser.rejected, handleError);
    builder.addCase(fetchAsyncGetLoginUser.pending, handleLoading);
    builder.addCase(
      fetchAsyncUpdateLoginUserEmail.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "メールを送信しました";
      }
    );
    builder.addCase(fetchAsyncUpdateLoginUserEmail.rejected, handleError);
    builder.addCase(fetchAsyncUpdateLoginUserEmail.pending, handleLoading);
    builder.addCase(
      fetchAsyncUpdateCompleteLoginUserEmail.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "メールの更新に完了しました";
      }
    );
    builder.addCase(
      fetchAsyncUpdateCompleteLoginUserEmail.rejected,
      handleError
    );
    builder.addCase(
      fetchAsyncUpdateCompleteLoginUserEmail.pending,
      handleLoading
    );
    builder.addCase(
      fetchAsyncUpdateLoginUsername.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "ユーザー名の更新に成功しました";
      }
    );
    builder.addCase(fetchAsyncUpdateLoginUsername.rejected, handleError);
    builder.addCase(fetchAsyncUpdateLoginUsername.pending, handleLoading);
    builder.addCase(
      fetchAsyncUpdateLoginUserPassword.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "パスワードの更新に成功しました";
      }
    );
    builder.addCase(fetchAsyncUpdateLoginUserPassword.rejected, handleError);
    builder.addCase(fetchAsyncUpdateLoginUserPassword.pending, handleLoading);
    builder.addCase(
      fetchAsyncResetPasswordRequest.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "メールを送信しました";
      }
    );
    builder.addCase(fetchAsyncResetPasswordRequest.rejected, handleError);
    builder.addCase(fetchAsyncResetPasswordRequest.pending, handleLoading);
    builder.addCase(
      fetchAsyncResetPassword.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "パスワードをリセットしました";
      }
    );
    builder.addCase(fetchAsyncResetPassword.rejected, handleError);
    builder.addCase(fetchAsyncResetPassword.pending, handleLoading);
    builder.addCase(
      fetchAsyncUpdateUserGroup.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "ユーザーグループの更新に成功しました";
      }
    );
    builder.addCase(fetchAsyncUpdateUserGroup.rejected, handleError);
    builder.addCase(fetchAsyncUpdateUserGroup.pending, handleLoading);
    builder.addCase(
      fetchAsyncDeleteLoginUser.fulfilled,
      (state, action: PayloadAction<USER>) => {
        state.status = "succeeded";
        state.loginUser = action.payload;
        state.message = "ユーザーの削除に成功しました";
      }
    );
    builder.addCase(fetchAsyncDeleteLoginUser.rejected, handleError);
    builder.addCase(fetchAsyncDeleteLoginUser.pending, handleLoading);
  },
});

export const { setLoginUser, editUserStatus, editUserMessage } =
  userSlice.actions;
export const selectLoginUser = (state: RootState) => state.user.loginUser;
export const selectUserStatus = (state: RootState) => state.user.status;
export const selectUserMessage = (state: RootState) => state.user.message;

export default userSlice.reducer;
