import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { Provider } from "react-redux";
import store from "./store";
import App from "./App";

test("renders the application", () => {
  render(
    <Provider store={store}>
      <MemoryRouter>
        <App />
      </MemoryRouter>
    </Provider>
  );

  expect(screen.getByRole("main")).toBeInTheDocument();
});