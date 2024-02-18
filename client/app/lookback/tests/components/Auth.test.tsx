import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import "@testing-library/jest-dom";
import { Provider } from "react-redux";
import { store } from "../../store/store";
import Auth from "@/components/Auth";

describe("<Auth />", () => {
  test("renders the Auth component", () => {
    render(
      <Provider store={store}>
        <Auth />
      </Provider>,
    );

    const allLoginElements = screen.getAllByText("Login");
    expect(allLoginElements).toHaveLength(2);
    expect(screen.getByLabelText("Email")).toBeInTheDocument();
    expect(screen.getByLabelText("Password")).toBeInTheDocument();
  });

  test("handles button clicks correctly", async () => {
    render(
      <Provider store={store}>
        <Auth />
      </Provider>,
    );

    fireEvent.click(screen.getByTestId("auth-button"));

    fireEvent.click(screen.getByText("アカウントを作成"));
    fireEvent.click(screen.getByText("Send Sign-up Email"));

    fireEvent.click(screen.getByText("ログインに戻る"));

    fireEvent.click(screen.getByText("こちら"));
    fireEvent.click(screen.getByText("Send Password-Reset Email"));

    fireEvent.click(screen.getByText("ログインに戻る"));

    fireEvent.click(screen.getByText("Login as a Guest"));
  });

});
