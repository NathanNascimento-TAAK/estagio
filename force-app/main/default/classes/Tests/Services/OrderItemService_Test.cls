@IsTest
private class OrderItemService_Test {
    @IsTest
    static void validatePercentagesAcceptsPositiveValues() {
        System.assertEquals(true, new OrderItemService().validatePercentages(10, 5, 8));
    }

    @IsTest
    static void validatePercentagesRejectsZeroOrNegativeValues() {
        OrderItemService service = new OrderItemService();

        System.assertEquals(false, service.validatePercentages(0, 5, 8));
        System.assertEquals(false, service.validatePercentages(10, 0, 8));
        System.assertEquals(false, service.validatePercentages(10, 5, 0));
        System.assertEquals(false, service.validatePercentages(-1, 5, 8));
        System.assertEquals(false, service.validatePercentages(10, -1, 8));
        System.assertEquals(false, service.validatePercentages(10, 5, -1));
    }

    @IsTest
    static void validatePercentagesRejectsNullValues() {
        OrderItemService service = new OrderItemService();

        System.assertEquals(false, service.validatePercentages(null, 5, 8));
        System.assertEquals(false, service.validatePercentages(10, null, 8));
        System.assertEquals(false, service.validatePercentages(10, 5, null));
    }
}
