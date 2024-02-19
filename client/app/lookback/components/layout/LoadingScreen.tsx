import LinearProgress from "@mui/material/LinearProgress";
import { useEffect, type ReactNode, useState } from "react";
import { useSelector } from "react-redux";
import { selectTaskStatus } from "@/slices/taskSlice";
import { selectUserGroupStatus } from "@/slices/userGroupSlice";
import { selectUserStatus } from "@/slices/userSlice";

type Props = {
  children: ReactNode;
};

export const LoadingScreen = ({ children }: Props) => {
  const taskStatus = useSelector(selectTaskStatus);
  const userStatus = useSelector(selectUserStatus);
  const userGroupStatus = useSelector(selectUserGroupStatus);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    console.log("taskStatus : " + taskStatus);
    if (
      taskStatus === "succeeded" ||
      taskStatus === "failed" ||
      taskStatus === ""
    ) {
      setIsLoading(false);
    } else if (taskStatus === "loading") {
      setIsLoading(true);
    }
  }, [taskStatus]);

  useEffect(() => {
    console.log("userStatus : " + userStatus);
    if (
      userGroupStatus === "succeeded" ||
      userGroupStatus === "failed" ||
      userGroupStatus === ""
    ) {
      setIsLoading(false);
    } else if (userGroupStatus === "loading") {
      setIsLoading(true);
    }
  }, [userGroupStatus]);

  useEffect(() => {
    console.log("userGroupStatus : " + userGroupStatus);
    if (
      userStatus === "succeeded" ||
      userStatus === "failed" ||
      userStatus === ""
    ) {
      setIsLoading(false);
    } else if (userStatus === "loading") {
      setIsLoading(true);
    }
  }, [userStatus]);

  return (
    <>
      <div>
        {isLoading ? (
          <div className="absolute top-0 left-0 right-0 bottom-0 flex flex-col justify-center items-center bg-white bg-opacity-50 z-10">
            <h2>Loading・・・</h2>
            <LinearProgress className="w-3/6" />
          </div>
        ) : null}

        <div className={`${isLoading ? "opacity-50" : ""}`}>{children}</div>
      </div>
    </>
  );
};
