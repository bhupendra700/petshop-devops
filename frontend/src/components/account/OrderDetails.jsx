import { Link, useLocation, useParams } from "react-router-dom";

import { FaAngleRight, FaAngleLeft } from "react-icons/fa6";

import ImageContainer from "../ImageContainer";

import { Row, Col, Table, Card, Button } from "react-bootstrap";

import { FaCheck, FaTimes } from "react-icons/fa";

import PayPalPayment from "../order/PayPalPayment";

import { useSelector } from "react-redux";

import {
  useGetOrderDetailsQuery,
  usePayOrderMutation,
  useDeliverOrderMutation,
} from "../../slices/ordersApiSlice";

import { toast } from "react-toastify";

const OrderDetails = () => {
  const { orderId } = useParams();
  const location = useLocation();

  const { userInfo } = useSelector((state) => state.auth);

  const segments = location.pathname.split("/");
  const slicedPath = segments[1];

  const isInAdmin = slicedPath === "admin" && userInfo?.isAdmin;

  const {
    data: order,
    refetch,
    isLoading,
    error,
  } = useGetOrderDetailsQuery(orderId);

  const isNotAuthorized =
    !isLoading &&
    order?.user?._id !== userInfo?._id &&
    !isInAdmin;

  const isAuthorized =
    !isLoading &&
    order &&
    (order?.user?._id === userInfo?._id || isInAdmin);

  // -----------------------------
  // PAY ORDER
  // -----------------------------

  const [payOrder, { isLoading: loadingPay }] = usePayOrderMutation();

  const payHandler = async () => {
    if (!window.confirm("Are you sure you want to mark this order as paid?")) {
      return;
    }

    try {
      await payOrder({
        orderId,
        details: {
          payer: {},
        },
      }).unwrap();

      await refetch();

      toast.success("Order is paid");
    } catch (err) {
      toast.error(
        err?.data?.message ||
          err?.error ||
          "Failed to update order"
      );
    }
  };

  // -----------------------------
  // DELIVER ORDER
  // -----------------------------

  const [deliverOrder, { isLoading: loadingDeliver }] =
    useDeliverOrderMutation();

  const deliverHandler = async () => {
    if (
      !window.confirm(
        "Are you sure you want to mark this order as delivered?"
      )
    ) {
      return;
    }

    try {
      await deliverOrder(orderId).unwrap();

      await refetch();

      toast.success("Order is delivered");
    } catch (err) {
      toast.error(
        err?.data?.message ||
          err?.error ||
          "Failed to update order"
      );
    }
  };

  // -----------------------------
  // PAYPAL PAYMENT
  // -----------------------------

  const onPaidHandler = async () => {
    await refetch();
  };

  const isShowPayPalBtn =
    order && !order.isPaid && !isInAdmin;

  // -----------------------------
  // UI
  // -----------------------------

  return (
    <div className="order-details">
      {/* Header */}

      {isInAdmin ? (
        <h6 className="fw-bold text-primary mt-3">
          <Link
            to="/admin/orders"
            className="text-primary back-link fs-5 me-1"
          >
            <FaAngleLeft />
          </Link>

          Order Details
        </h6>
      ) : (
        <h6 className="fw-bold text-primary">
          <Link
            to="/account"
            className="text-primary back-link"
          >
            Purchase History
          </Link>

          <FaAngleRight className="mx-1" />

          Order Details
        </h6>
      )}

      <div>
        {/* Loading */}

        {isLoading && (
          <p>Loading Order Details...</p>
        )}

        {/* Error */}

        {error ? (
          <p>
            Error:{" "}
            {error?.data?.message ||
              error?.error ||
              "Something went wrong"}
          </p>
        ) : (
          isNotAuthorized && (
            <p>
              You are not authorized to view this order
            </p>
          )
        )}

        {/* Order Details */}

        {isAuthorized && (
          <div>
            {/* Order Date */}

            <p className="mt-3">
              <span className="text-black-50">
                Ordered on
              </span>{" "}

              {order.createdAt.substring(0, 10)}

              &nbsp;&nbsp;

              <span className="text-black-50">
                {" | "}&nbsp;&nbsp;Order ID:
              </span>{" "}

              {orderId}
            </p>

            {/* Order Information */}

            <Card className="p-3">
              <Row>
                {/* User + Shipping */}

                <Col>
                  {isInAdmin && order.user && (
                    <>
                      <h6 className="order-lable">
                        User Info
                      </h6>

                      <p>
                        Name:{" "}

                        <Link
                          to={`/admin/users/${order.user._id}`}
                          className="text-black"
                        >
                          {order.user.name}
                        </Link>

                        <br />

                        ID: {order.user._id}

                        <br />

                        Email: {order.user.email}
                      </p>
                    </>
                  )}

                  <h6 className="order-lable">
                    Shipping Address
                  </h6>

                  <p>
                    {order.shippingAddress.firstName}{" "}
                    {order.shippingAddress.lastName}
                    <br />

                    {order.shippingAddress.address}
                    <br />

                    {order.shippingAddress.city},{" "}
                    {order.shippingAddress.postalCode},{" "}
                    {order.shippingAddress.country}
                  </p>
                </Col>

                {/* Order Summary */}

                <Col>
                  <h6 className="order-lable">
                    Order Summary
                  </h6>

                  <div>
                    <p>
                      Items: ${order.itemsPrice}
                      <br />

                      Shipping: ${order.shippingPrice}
                      <br />

                      Tax: ${order.taxPrice}
                      <br />

                      Total: ${order.totalPrice}
                    </p>
                  </div>
                </Col>

                {/* Payment + Status */}

                <Col>
                  <h6 className="order-lable">
                    Payment Method
                  </h6>

                  <p>
                    {order.paymentMethod}
                  </p>

                  <h6 className="order-lable">
                    Order Status
                  </h6>

                  {/* Paid Status */}

                  {order.isPaid ? (
                    <div>
                      <FaCheck className="text-success me-2" />

                      {order.paidAt
                        ? `Paid on ${order.paidAt.substring(
                            0,
                            10
                          )}`
                        : "Paid"}
                    </div>
                  ) : (
                    <div>
                      <FaTimes className="text-primary me-2" />

                      Not Paid
                    </div>
                  )}

                  {/* Delivered Status */}

                  {order.isDelivered ? (
                    <div>
                      <FaCheck className="text-success me-2" />

                      {order.deliveredAt
                        ? `Delivered on ${order.deliveredAt.substring(
                            0,
                            10
                          )}`
                        : "Delivered"}
                    </div>
                  ) : (
                    <div>
                      <FaTimes className="text-primary me-2" />

                      Not Delivered
                    </div>
                  )}

                  {/* PayPal */}

                  {isShowPayPalBtn && (
                    <PayPalPayment
                      order={order}
                      onPaid={onPaidHandler}
                    />
                  )}
                </Col>
              </Row>
            </Card>

            {/* Order Items */}

            <Card className="p-3 mt-4">
              <Table className="table table-striped table-hover table-style">
                <thead>
                  <tr>
                    <th>Product</th>
                    <th></th>
                    <th>Quantity</th>
                    <th>Price</th>
                    <th>Total</th>
                  </tr>
                </thead>

                <tbody>
                  {order.orderItems.map((item) => (
                    <tr key={item.product}>
                      {/* Image */}

                      <td style={{ width: "50px" }}>
                        <Link
                          to={`/product/${item.product}`}
                        >
                          <ImageContainer
                            src={item.image}
                            alt={item.name}
                            className="img-thumbnail"
                            size="48px"
                          />
                        </Link>
                      </td>

                      {/* Name */}

                      <td>
                        <Link
                          to={`/product/${item.product}`}
                          className="text-black"
                        >
                          {item.name}
                        </Link>
                      </td>

                      {/* Quantity */}

                      <td>
                        {item.qty}
                      </td>

                      {/* Price */}

                      <td>
                        {item.isOnSale ? (
                          <span>
                            <span className="text-decoration-line-through text-black-50">
                              ${item.price}
                            </span>

                            <span className="ms-2">
                              ${item.salePrice}
                            </span>
                          </span>
                        ) : (
                          <span>
                            ${item.price}
                          </span>
                        )}
                      </td>

                      {/* Total */}

                      <td>
                        {item.isOnSale ? (
                          <span>
                            $
                            {(
                              item.qty *
                              item.salePrice
                            ).toFixed(2)}
                          </span>
                        ) : (
                          <span>
                            $
                            {(
                              item.qty *
                              item.price
                            ).toFixed(2)}
                          </span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </Table>
            </Card>

            {/* Admin Controls */}

            {isInAdmin && (
              <Card className="p-3 mt-4">
                <h6 className="order-lable">
                  Update Order Status
                </h6>

                <p className="mt-2 mb-0">
                  {/* Mark As Paid */}

                  <Button
                    onClick={payHandler}
                    disabled={
                      loadingPay || order.isPaid
                    }
                    className="rounded-pill px-3 me-4"
                    size="sm"
                  >
                    {loadingPay
                      ? "Updating..."
                      : "Mark As Paid"}
                  </Button>

                  {/* Mark As Delivered */}

                  <Button
                    onClick={deliverHandler}
                    disabled={
                      loadingDeliver ||
                      order.isDelivered
                    }
                    className="rounded-pill px-3"
                    size="sm"
                  >
                    {loadingDeliver
                      ? "Updating..."
                      : "Mark As Delivered"}
                  </Button>
                </p>
              </Card>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default OrderDetails;