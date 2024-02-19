import { Grid } from "@mui/material";
import Head from "next/head";
import type { ReactNode } from "react";
import { AuthPageHeader } from "./AuthPageHeader";
import { LoadingScreen } from "./LoadingScreen";
import { MessageBar } from "./MessageBar";

type Props = {
  children: ReactNode;
  title: string;
};

export const AuthPageLayout = ({ children, title }: Props) => {
  return (
    <>
      <Head>
        <title>{title}</title>
      </Head>
      <LoadingScreen>
        <main className="text-center text-gray-600 font-serif m-6">
          <Grid container>
            <AuthPageHeader title="Look Back" />
            {children}
          </Grid>
        </main>
      </LoadingScreen>
      <MessageBar />
    </>
  );
};
