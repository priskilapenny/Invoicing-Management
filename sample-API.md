# API Endpoint Documentation

## 1. Retrieve Invoices

**Endpoint:** `GET /invoices/?occupied_id={id}`

**Purpose:** Retrieve invoice list based on occupied_id.

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `occupied_id` | Integer | Unique occupied identifier |


**Source code:**
````python
def get(self, request, *args, **kwargs):
        occupiedId = request.GET.get('occupied_id')
        invstatus = request.GET.get('invoice_status_id')
        sdate = request.GET.get('sdate')
        edate = request.GET.get('edate')
        search = request.GET.get('search')
        with connection.cursor() as cursor:
            cursor.callproc('invoice_list',[occupiedId, invstatus, sdate, edate, search])
            columns = [col[0] for col in cursor.description]
            result = [dict(zip(columns, row)) for row in cursor.fetchall()]
        page = self.paginate_queryset(result)

        if page is not None:
            serializer = self.get_paginated_response(page)
        else:
            serializer = self.serializer_class(page, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)
````

**Response:**

```json
{
    "occupied_id": 111,
    "invoice_id": 400,
    "invoice_name": "December 2025",
    "invoice_type_id": 1,
    "invoice_type": "With Utility",
    "due_date": "2025-12-24",
    "invoice_status_id": 4,
    "invoice_status": "Confirmation Required",
    "date_create": "2025-12-23"
}
```

## 2. Create New Invoice
**Endpoint:** `GET /invoices/`

**Purpose:** Create a new invoice.

**Body Parameters:**
```json
{
  "occupied_id": 1,
  "invoice_name": "December 2025",
  "invoice_type": 1
}
```

**Source code:**  
```python
def post(self, request, *args, **kwargs):
        occupiedId = request.data.get('occupied_id')
        invoice_type = request.data.get('invoice_type')

        if int(invoice_type) == 1:
            invstatus = 1
        else:
            invstatus = 2
            
        data = {
            # 'invoice_number': invdate,
            'occupied_id': occupiedId,
            'invoice_name': request.data.get('invoice_name'),
            'invoice_type_id': invoice_type,
            'invoice_status': invstatus,
            'due_date': request.data.get('due_date')
        }

        serializer = invoiceSerializer(data=data)
        if serializer.is_valid():
            newinv = serializer.save()
            invid = newinv.pk
            
            occupied = OccupiedBungalow.objects.filter(occupied_id=occupiedId).first()
            
            # update invoice number
            bungalowid = occupied.bungalow_id
            datenow = datetime.today()
            invdate = datenow.strftime('%y%m%d')
            joinnum = ('', invdate, str(bungalowid), str(invid))
            invNum = ''.join(joinnum)
            
            invoice = Invoices.objects.filter(invoice_id=invid).first()
            invoice.invoice_number = invNum
            invoice.save()
            
            # update inv status on occupied bungalow
            occupied.last_invoice = invid
            occupied.invoice_status_id = invstatus
            occupied.save()
                        
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
```
