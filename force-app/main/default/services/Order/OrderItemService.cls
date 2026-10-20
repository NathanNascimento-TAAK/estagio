public with sharing class OrderItemService {
    public Boolean validatePercentages(Decimal marginPercentage, Decimal shippingCost, Decimal taxPercentage) {
        if(marginPercentage > 0 && shippingCost > 0 && taxPercentage > 0) {
            return true;
        }
        else if(marginPercentage == null || shippingCost == null || taxPercentage == null) {
            return false;
        }
        else return false;
    }

}