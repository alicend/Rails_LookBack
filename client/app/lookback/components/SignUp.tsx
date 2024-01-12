import { TextField, Button, Grid } from "@mui/material";
import { styled } from "@mui/system";
import React, { useState } from "react";
import { useDispatch } from "react-redux";
import { z } from "zod";

import { AppDispatch } from "../store/store";
import {
  fetchAsyncLogin,
  fetchAsyncRegister,
  fetchAsyncInviteRegister,
} from "@/slices/userSlice";

const StyledButton = styled(Button)(({ theme }) => ({
  backgroundColor: "#4dabf5 !important",
  "&:hover": {
    backgroundColor: "#1769aa !important",
  },
  "&:disabled": {
    backgroundColor: "#ccc !important",
    cursor: "not-allowed",
  },
  margin: theme.spacing(3),
}));

const StyledTextField = styled(TextField)(({ theme }) => ({
  "& .MuiInputLabel-root": {
    marginBottom: theme.spacing(1),
  },
  "& .MuiInput-root": {
    marginBottom: theme.spacing(2),
  },
  width: "300px",
}));

// 少なくとも1つの英字と1つの数字を含む
const passwordCheck = (val: string) =>
  /[A-Za-z].*[0-9]|[0-9].*[A-Za-z]/.test(val);
const pattern = /^[\u0021-\u007e]+$/u; // 半角英数字記号のみ

const registerCredentialSchema = z.object({
  email: z
    .string()
    .email("無効なメールアドレスです")
    .regex(pattern, "無効なメールアドレスです"),
  password: z
    .string()
    .min(8, "パスワードは８文字以上にしてください")
    .refine(
      passwordCheck,
      "パスワードには少なくとも１つ以上の半角英字と半角数字を含めてください",
    ),
  username: z.string(),
  user_group: z.string(),
});

const inviteRegisterCredentialSchema = z.object({
  email: z
    .string()
    .email("無効なメールアドレスです")
    .regex(pattern, "無効なメールアドレスです"),
  password: z
    .string()
    .min(8, "パスワードは８文字以上にしてください")
    .refine(
      passwordCheck,
      "パスワードには少なくとも１つ以上の半角英字と半角数字を含めてください",
    ),
  username: z.string(),
});

interface Props {
  email: string;
  userGroupID: string;
}

const SignUp: React.FC<Props> = ({ email, userGroupID }) => {
  const dispatch: AppDispatch = useDispatch();
  const [credential, setCredential] = useState({
    email: email,
    password: "",
    username: "",
    user_group: userGroupID,
  });
  const [errors, setErrors] = useState({
    username: "",
    password: "",
    user_group: "",
  });
  console.log(userGroupID)
  console.log(userGroupID)

  let isDisabled = true;
  if (userGroupID !== "") {
    isDisabled =
      credential.username.length === 0 ||
      credential.password.length === 0 ||
      credential.email.length === 0;
  } else {
    isDisabled =
      credential.username.length === 0 ||
      credential.password.length === 0 ||
      credential.email.length === 0 ||
      credential.user_group.length === 0;
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    const name = e.target.name;
    setCredential({ ...credential, [name]: value });
    setErrors({ ...errors, [name]: "" });
  };

  const register = async () => {
    // 入力チェック
    const result = registerCredentialSchema.safeParse(credential);
    if (!result.success) {
      const usernameError =
        result.error.formErrors.fieldErrors["username"]?.[0] || "";
      const passwordError =
        result.error.formErrors.fieldErrors["password"]?.[0] || "";
      const userGroupError =
        result.error.formErrors.fieldErrors["user_group"]?.[0] || "";
      setErrors({
        username: usernameError,
        password: passwordError,
        user_group: userGroupError,
      });
      return;
    }

    // 登録処理
    const action = await dispatch(fetchAsyncRegister(credential));

    if (fetchAsyncRegister.fulfilled.match(action)) {
      // 登録成功時、自動的にログインを行う
      await dispatch(fetchAsyncLogin(credential));
    }
  };

  const registerInvite = async () => {
    // 入力チェック
    const result = inviteRegisterCredentialSchema.safeParse(credential);
    if (!result.success) {
      const usernameError =
        result.error.formErrors.fieldErrors["username"]?.[0] || "";
      const passwordError =
        result.error.formErrors.fieldErrors["password"]?.[0] || "";
      const userGroupError = "";
      setErrors({
        username: usernameError,
        password: passwordError,
        user_group: userGroupError,
      });
      return;
    }
    if (userGroupID !== "") {
      setCredential({ ...credential, user_group: userGroupID });
    } else {
      console.error("userGroupID is null");
      return;
    }

    // 登録処理
    const action = await dispatch(fetchAsyncInviteRegister(credential));

    if (fetchAsyncRegister.fulfilled.match(action)) {
      // 登録成功時、自動的にログインを行う
      await dispatch(fetchAsyncLogin(credential));
    }
  };

  return (
    <>
      <Grid
        container
        direction="column"
        justifyContent="center"
        alignItems="center"
        style={{ minHeight: "80vh", padding: "12px" }}
      >
        <Grid item>
          <h1>Sign Up</h1>
        </Grid>
        <br />
        <Grid item>
          <StyledTextField
            InputLabelProps={{
              shrink: true,
            }}
            label="Email"
            type="email"
            name="email"
            value={credential.email}
            disabled={true}
          />
        </Grid>
        <br />
        <Grid item>
          <StyledTextField
            InputLabelProps={{
              shrink: true,
            }}
            label="Password"
            type="password"
            name="password"
            value={credential.password}
            onChange={handleInputChange}
            error={Boolean(errors.password)}
            helperText={errors.password}
          />
        </Grid>

        <br />
        <Grid item>
          <StyledTextField
            InputLabelProps={{
              shrink: true,
            }}
            label="Username"
            type="text"
            name="username"
            value={credential.username}
            onChange={handleInputChange}
            error={Boolean(errors.username)}
            helperText={errors.username}
            inputProps={{
              maxLength: 30,
            }}
          />
        </Grid>

        {userGroupID !== "" ? "" : (
          <>
            <br />
            <Grid item>
              <StyledTextField
                InputLabelProps={{
                  shrink: true,
                }}
                label="User Group"
                type="text"
                name="user_group"
                value={credential.user_group}
                onChange={handleInputChange}
                error={Boolean(errors.user_group)}
                helperText={errors.user_group}
                inputProps={{
                  maxLength: 30,
                }}
              />
            </Grid>
          </>
        )}

        <Grid item>
          <StyledButton
            data-testid="signup-button"
            variant="contained"
            color="primary"
            size="small"
            disabled={isDisabled}
            onClick={userGroupID !== "" ? registerInvite : register}
          >
            Sign Up
          </StyledButton>
        </Grid>
      </Grid>
    </>
  );
};

export default SignUp;
